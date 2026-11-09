using AutoMapper;
using Barberia.Application.DTOs.Barberias;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services.Barberias;
using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using Barberia.Shared.Constants;
using BarberiaEntity = Barberia.Domain.Entities.Barberia;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using AppValidationException = Barberia.Application.Exceptions.ValidationException;

namespace Barberia.Application.Services;

public sealed class BarberiaService : IBarberiaService
{
    private readonly IBarberiaDbContext dbContext;
    private readonly IMapper mapper;
    private readonly IValidator<UpsertBarberiaRequest> upsertValidator;
    private readonly TimeProvider timeProvider;

    public BarberiaService(
        IBarberiaDbContext dbContext,
        IMapper mapper,
        IValidator<UpsertBarberiaRequest> upsertValidator,
        TimeProvider timeProvider)
    {
        this.timeProvider = timeProvider;
        this.dbContext = dbContext;
        this.mapper = mapper;
        this.upsertValidator = upsertValidator;
    }

    public async Task<List<BarberiaDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var barberias = await dbContext.Barberias
            .AsNoTracking()
            .Where(x => x.Activo)
            .OrderByDescending(x => x.Activa)
            .ThenBy(x => x.Nombre)
            .ToListAsync(cancellationToken);

        return mapper.Map<List<BarberiaDto>>(barberias);
    }

    public async Task<BarberiaDto> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var barberia = await dbContext.Barberias
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.Activo, cancellationToken);

        if (barberia is null)
        {
            throw new NotFoundException("La barbería solicitada no existe.");
        }

        return mapper.Map<BarberiaDto>(barberia);
    }

    public async Task<BarberiaDto> UpdateAsync(Guid id, UpsertBarberiaRequest request, CancellationToken cancellationToken)
    {
        await ValidateAsync(request, cancellationToken);

        var barberia = await dbContext.Barberias
            .FirstOrDefaultAsync(x => x.Id == id && x.Activo, cancellationToken);

        if (barberia is null)
        {
            throw new NotFoundException("La barbería no existe.");
        }

        Aplicar(barberia, request);

        await dbContext.SaveChangesAsync(cancellationToken);

        return mapper.Map<BarberiaDto>(barberia);
    }

    public async Task<BarberiaDto> CrearAsync(CrearBarberiaRequest request, CancellationToken cancellationToken)
    {
        await ValidateAsync(request, cancellationToken);
        var admin = request.Administrador;
        var correoAdmin = admin.Correo.Trim().ToLowerInvariant();
        var errores = new List<string>();
        if (string.IsNullOrWhiteSpace(admin.Nombre)) errores.Add("Escribe el nombre del administrador.");
        if (string.IsNullOrWhiteSpace(admin.Apellido)) errores.Add("Escribe el apellido del administrador.");
        if (!System.Text.RegularExpressions.Regex.IsMatch(correoAdmin, @"^[^@\s]+@[^@\s]+\.[^@\s]{2,}$")) errores.Add("Escribe un correo válido para el administrador.");
        if ((admin.Password ?? string.Empty).Length < 6) errores.Add("La contraseña del administrador debe tener al menos 6 caracteres.");
        if (errores.Count > 0)
        {
            throw new AppValidationException("Revisa los datos del administrador.", errores.ToArray());
        }

        var barberia = new BarberiaEntity();
        Aplicar(barberia, request);

        // Barbería y administrador se guardan juntos: o quedan los dos o ninguno.
        dbContext.Barberias.Add(barberia);
        dbContext.Clientes.Add(new Cliente
        {
            BarberiaId = barberia.Id,
            Rol = Roles.AdminBarberia,
            Nombre = admin.Nombre.Trim(),
            Apellido = admin.Apellido.Trim(),
            Telefono = admin.Telefono?.Trim() ?? string.Empty,
            Correo = correoAdmin,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(admin.Password),
        });
        await dbContext.SaveChangesAsync(cancellationToken);

        return mapper.Map<BarberiaDto>(barberia);
    }

    public async Task<BarberiaDto> CambiarEstadoAsync(Guid id, bool activa, CancellationToken cancellationToken)
    {
        var barberia = await dbContext.Barberias.FirstOrDefaultAsync(x => x.Id == id && x.Activo, cancellationToken)
            ?? throw new NotFoundException("La barbería no existe.");

        barberia.Activa = activa;
        await dbContext.SaveChangesAsync(cancellationToken);

        return mapper.Map<BarberiaDto>(barberia);
    }

    public async Task<List<ResumenBarberiaDto>> ResumenAsync(CancellationToken cancellationToken)
    {
        var colombia = TimeZoneInfo.FindSystemTimeZoneById("America/Bogota");
        var hoy = DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(timeProvider.GetUtcNow(), colombia).DateTime);
        var desde = new DateOnly(hoy.Year, hoy.Month, 1);
        var hasta = desde.AddMonths(1);

        var citas = await dbContext.Citas.AsNoTracking()
            .Where(x => x.FechaCita >= desde && x.FechaCita < hasta && x.Estado != EstadoCita.Cancelada && x.Estado != EstadoCita.NoShow)
            .GroupBy(x => x.BarberiaId)
            .Select(g => new
            {
                BarberiaId = g.Key,
                Citas = g.Count(),
                Ingresos = g.Where(x => x.Estado == EstadoCita.Completada).Sum(x => x.PrecioFinal),
            })
            .ToDictionaryAsync(x => x.BarberiaId, cancellationToken);
        var clientes = await dbContext.Clientes.AsNoTracking()
            .Where(x => x.Activo && x.Rol == Roles.Cliente && x.BarberiaId != null)
            .GroupBy(x => x.BarberiaId!.Value)
            .Select(g => new { BarberiaId = g.Key, Total = g.Count() })
            .ToDictionaryAsync(x => x.BarberiaId, x => x.Total, cancellationToken);
        var barberos = await dbContext.Barberos.AsNoTracking()
            .Where(x => x.Activo)
            .GroupBy(x => x.BarberiaId)
            .Select(g => new { BarberiaId = g.Key, Total = g.Count() })
            .ToDictionaryAsync(x => x.BarberiaId, x => x.Total, cancellationToken);

        var barberias = await dbContext.Barberias.AsNoTracking()
            .Where(x => x.Activo)
            .OrderBy(x => x.Nombre)
            .ToListAsync(cancellationToken);

        return barberias.Select(b => new ResumenBarberiaDto
        {
            BarberiaId = b.Id,
            Nombre = b.Nombre,
            Activa = b.Activa,
            CitasMes = citas.TryGetValue(b.Id, out var c) ? c.Citas : 0,
            IngresosMes = citas.TryGetValue(b.Id, out var i) ? i.Ingresos : 0,
            Clientes = clientes.GetValueOrDefault(b.Id),
            BarberosActivos = barberos.GetValueOrDefault(b.Id),
        }).ToList();
    }

    private static void Aplicar(BarberiaEntity barberia, UpsertBarberiaRequest request)
    {
        barberia.Nombre = request.Nombre.Trim();
        barberia.Descripcion = request.Descripcion?.Trim() ?? string.Empty;
        barberia.Slogan = request.Slogan?.Trim() ?? string.Empty;
        barberia.Telefono = request.Telefono.Trim();
        barberia.Correo = request.Correo.Trim().ToLowerInvariant();
        barberia.SitioWeb = request.SitioWeb?.Trim() ?? string.Empty;
        barberia.Direccion = request.Direccion.Trim();
        barberia.Ciudad = request.Ciudad.Trim();
        barberia.Departamento = request.Departamento.Trim();
        barberia.Pais = request.Pais.Trim();
        barberia.Latitud = request.Latitud;
        barberia.Longitud = request.Longitud;
        barberia.FotoPortada = request.FotoPortada?.Trim() ?? string.Empty;
        barberia.HoraApertura = request.HoraApertura;
        barberia.HoraCierre = request.HoraCierre;
        barberia.DiasDescanso = ParseDiasDescanso(request.DiasDescanso);
        barberia.Activa = request.Activa;
    }

    private async Task ValidateAsync(UpsertBarberiaRequest request, CancellationToken cancellationToken)
    {
        var validationResult = await upsertValidator.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            throw new AppValidationException(
                "La solicitud contiene errores de validación.",
                validationResult.Errors.Select(x => x.ErrorMessage).ToArray());
        }
    }

    private static List<DiaSemana> ParseDiasDescanso(List<string> diasDescanso)
    {
        var result = new List<DiaSemana>();

        foreach (var dia in diasDescanso)
        {
            if (string.IsNullOrWhiteSpace(dia))
            {
                continue;
            }

            if (!Enum.TryParse<DiaSemana>(dia.Trim(), ignoreCase: true, out var parsed))
            {
                throw new AppValidationException($"Día de descanso inválido: {dia}");
            }

            result.Add(parsed);
        }

        return result.Distinct().ToList();
    }
}
