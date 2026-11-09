using System.Security.Cryptography;
using Barberia.Application.DTOs.Auth;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Interfaces.Services.Auth;
using Barberia.Application.Interfaces.Services.Barberias;
using Barberia.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Application.Services;

/// <summary>
/// Recuperar contraseña con un código de 6 dígitos por correo. Nunca revela si
/// un correo existe: solicitar responde igual, y restablecer da un solo error
/// para correo desconocido, código malo, vencido, usado o bloqueado.
/// </summary>
public sealed class RecuperacionPasswordService(
    IBarberiaDbContext dbContext,
    IEmailSender emailSender,
    TimeProvider timeProvider,
    IBarberiaContexto barberiaContexto) : IRecuperacionPasswordService
{
    public static readonly TimeSpan Vigencia = TimeSpan.FromMinutes(15);
    private static readonly TimeSpan EsperaEntreCodigos = TimeSpan.FromSeconds(60);
    private const int MaxIntentos = 5;
    private const string CodigoInvalido = "El código no es válido o ya venció. Pide uno nuevo.";

    public async Task SolicitarCodigoAsync(SolicitarCodigoRequest request, CancellationToken cancellationToken)
    {
        var correo = Normalizar(request.Correo);
        var cliente = await BuscarCuentaAsync(correo, cancellationToken);
        if (cliente is null)
        {
            return;
        }

        var ahora = Ahora();
        var vigentes = await dbContext.CodigosRecuperacion.Where(x => x.ClienteId == cliente.Id && x.Activo).ToListAsync(cancellationToken);
        if (vigentes.Any(x => ahora - x.EmitidoEn < EsperaEntreCodigos))
        {
            return;
        }

        foreach (var anterior in vigentes)
        {
            anterior.Activo = false;
        }

        var codigo = RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");
        dbContext.CodigosRecuperacion.Add(new CodigoRecuperacion
        {
            ClienteId = cliente.Id,
            CodigoHash = BCrypt.Net.BCrypt.HashPassword(codigo),
            EmitidoEn = ahora,
            ExpiraEn = ahora.Add(Vigencia),
        });
        await dbContext.SaveChangesAsync(cancellationToken);

        await emailSender.EnviarAsync(
            cliente.Correo,
            "Tu código para cambiar la contraseña",
            $"Hola, {cliente.Nombre}:\n\nTu código es {codigo}. Vence en 15 minutos.\n\nSi no pediste cambiar tu contraseña, ignora este correo: tu cuenta sigue igual.\n\nBarberShop Medellín",
            cancellationToken);
    }

    public async Task RestablecerAsync(RestablecerPasswordRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(request.NuevaPassword) || request.NuevaPassword.Length < 6)
        {
            throw new ValidationException("La contraseña debe tener al menos 6 caracteres.");
        }

        var correo = Normalizar(request.Correo);
        var cliente = await BuscarCuentaAsync(correo, cancellationToken)
            ?? throw new ValidationException(CodigoInvalido);

        var ahora = Ahora();
        var vigente = await dbContext.CodigosRecuperacion
            .Where(x => x.ClienteId == cliente.Id && x.Activo)
            .OrderByDescending(x => x.EmitidoEn)
            .FirstOrDefaultAsync(cancellationToken);
        if (vigente is null || vigente.ExpiraEn <= ahora || vigente.Intentos >= MaxIntentos)
        {
            throw new ValidationException(CodigoInvalido);
        }

        if (!BCrypt.Net.BCrypt.Verify((request.Codigo ?? string.Empty).Trim(), vigente.CodigoHash))
        {
            vigente.Intentos++;
            await dbContext.SaveChangesAsync(cancellationToken);
            throw new ValidationException(CodigoInvalido);
        }

        vigente.Activo = false;
        vigente.UsadoEn = ahora;
        cliente.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NuevaPassword);
        await dbContext.SaveChangesAsync(cancellationToken);

        await emailSender.EnviarAsync(
            cliente.Correo,
            "Tu contraseña cambió",
            $"Hola, {cliente.Nombre}:\n\nTu contraseña se cambió hace un momento. Ya puedes entrar con la nueva.\n\nSi no fuiste tú, escríbenos o pide un código nuevo para cambiarla otra vez.\n\nBarberShop Medellín",
            cancellationToken);
    }

    /// <summary>
    /// Con barbería: la cuenta de esa barbería, o la del SuperAdmin. Sin barbería (desde el
    /// panel): solo si el correo es de una única cuenta; si hay varias no se adivina.
    /// </summary>
    private async Task<Cliente?> BuscarCuentaAsync(string correo, CancellationToken cancellationToken)
    {
        var barberiaId = await barberiaContexto.ObtenerIdSiHayAsync(cancellationToken);
        var cuentas = await dbContext.Clientes
            .IgnoreQueryFilters()
            .Where(x => x.Correo == correo && x.Activo && (barberiaId == null || x.BarberiaId == barberiaId || x.BarberiaId == null))
            .OrderBy(x => x.BarberiaId == null)
            .Take(2)
            .ToListAsync(cancellationToken);

        return barberiaId is null && cuentas.Count > 1 ? null : cuentas.FirstOrDefault();
    }

    private DateTime Ahora() => timeProvider.GetUtcNow().UtcDateTime;

    private static string Normalizar(string? correo) => (correo ?? string.Empty).Trim().ToLowerInvariant();
}
