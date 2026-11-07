using System.Text.RegularExpressions;
using Barberia.Application.DTOs.Auth;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Services;
using Barberia.Domain.Entities;
using Barberia.Tests.Gestion;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.Auth;

// Recuperar contraseña: código de 6 dígitos por correo, 15 minutos, 5 intentos.
public sealed class RecuperacionPasswordServiceTests : GestionTestBase
{
    private sealed class FakeEmailSender : IEmailSender
    {
        public List<(string Para, string Asunto, string Cuerpo)> Enviados { get; } = [];

        public Task EnviarAsync(string destinatario, string asunto, string cuerpo, CancellationToken cancellationToken)
        {
            Enviados.Add((destinatario, asunto, cuerpo));
            return Task.CompletedTask;
        }

        public string UltimoCodigo => Regex.Match(Enviados.Last().Cuerpo, @"\b\d{6}\b").Value;
    }

    private const string Correo = "laura@correo.co";
    private readonly FakeEmailSender correo = new();
    private readonly Guid clienteId = Guid.NewGuid();

    private RecuperacionPasswordService NewService() => new(NewContext(), correo, Clock);

    private async Task SembrarAsync(bool activo = true)
    {
        await using var seed = NewContext();
        seed.Clientes.Add(new Cliente { Id = clienteId, Nombre = "Laura", Apellido = "Henao", Correo = Correo, PasswordHash = BCrypt.Net.BCrypt.HashPassword("vieja123"), Activo = activo });
        await seed.SaveChangesAsync();
    }

    private Task Solicitar(string c = Correo) => NewService().SolicitarCodigoAsync(new SolicitarCodigoRequest { Correo = c }, CancellationToken.None);

    private Task Restablecer(string codigo, string nueva = "nueva123", string c = Correo) =>
        NewService().RestablecerAsync(new RestablecerPasswordRequest { Correo = c, Codigo = codigo, NuevaPassword = nueva }, CancellationToken.None);

    private async Task<string> HashActualAsync()
    {
        await using var ctx = NewContext();
        return (await ctx.Clientes.AsNoTracking().SingleAsync(x => x.Id == clienteId)).PasswordHash;
    }

    [Fact]
    public async Task Solicitar_envia_un_codigo_de_6_digitos_al_correo_de_la_cuenta()
    {
        await SembrarAsync();

        await Solicitar("  Laura@Correo.co ");

        var enviado = Assert.Single(correo.Enviados);
        Assert.Equal(Correo, enviado.Para);
        Assert.Matches(@"^\d{6}$", correo.UltimoCodigo);
        Assert.Contains("15 minutos", enviado.Cuerpo);
    }

    [Fact]
    public async Task Solicitar_con_un_correo_desconocido_o_inactivo_no_envia_nada_ni_falla()
    {
        await SembrarAsync(activo: false);

        await Solicitar();
        await Solicitar("nadie@correo.co");

        Assert.Empty(correo.Enviados);
    }

    [Fact]
    public async Task Solicitar_dos_veces_en_menos_de_un_minuto_envia_un_solo_codigo()
    {
        await SembrarAsync();

        await Solicitar();
        Clock.Advance(TimeSpan.FromSeconds(30));
        await Solicitar();

        Assert.Single(correo.Enviados);
    }

    [Fact]
    public async Task Restablecer_con_el_codigo_correcto_cambia_la_contrasena_y_avisa_por_correo()
    {
        await SembrarAsync();
        await Solicitar();

        await Restablecer(correo.UltimoCodigo, "nueva123");

        Assert.True(BCrypt.Net.BCrypt.Verify("nueva123", await HashActualAsync()));
        Assert.Contains("cambió", correo.Enviados.Last().Asunto);
    }

    [Fact]
    public async Task El_codigo_sirve_una_sola_vez()
    {
        await SembrarAsync();
        await Solicitar();
        var codigo = correo.UltimoCodigo;
        await Restablecer(codigo, "nueva123");

        var ex = await Assert.ThrowsAsync<ValidationException>(() => Restablecer(codigo, "otra1234"));

        Assert.Equal("El código no es válido o ya venció. Pide uno nuevo.", ex.Message);
        Assert.True(BCrypt.Net.BCrypt.Verify("nueva123", await HashActualAsync()));
    }

    [Fact]
    public async Task Un_codigo_vencido_no_sirve()
    {
        await SembrarAsync();
        await Solicitar();
        Clock.Advance(TimeSpan.FromMinutes(16));

        await Assert.ThrowsAsync<ValidationException>(() => Restablecer(correo.UltimoCodigo));

        Assert.True(BCrypt.Net.BCrypt.Verify("vieja123", await HashActualAsync()));
    }

    [Fact]
    public async Task Pedir_un_codigo_nuevo_invalida_el_anterior()
    {
        await SembrarAsync();
        await Solicitar();
        var primero = correo.UltimoCodigo;
        Clock.Advance(TimeSpan.FromMinutes(2));
        await Solicitar();

        Assert.Equal(2, correo.Enviados.Count);
        var segundo = correo.UltimoCodigo;
        if (primero != segundo)
        {
            await Assert.ThrowsAsync<ValidationException>(() => Restablecer(primero));
        }

        await Restablecer(segundo);
        Assert.True(BCrypt.Net.BCrypt.Verify("nueva123", await HashActualAsync()));
    }

    [Fact]
    public async Task Tras_5_intentos_fallidos_el_codigo_se_bloquea_aunque_luego_sea_correcto()
    {
        await SembrarAsync();
        await Solicitar();
        var bueno = correo.UltimoCodigo;
        var malo = bueno == "000000" ? "111111" : "000000";

        for (var i = 0; i < 5; i++)
        {
            await Assert.ThrowsAsync<ValidationException>(() => Restablecer(malo));
        }

        await Assert.ThrowsAsync<ValidationException>(() => Restablecer(bueno));
        Assert.True(BCrypt.Net.BCrypt.Verify("vieja123", await HashActualAsync()));
    }

    [Theory]
    [InlineData("12345")]
    [InlineData("")]
    public async Task La_nueva_contrasena_necesita_al_menos_6_caracteres(string nueva)
    {
        await SembrarAsync();
        await Solicitar();

        var ex = await Assert.ThrowsAsync<ValidationException>(() => Restablecer(correo.UltimoCodigo, nueva));

        Assert.Equal("La contraseña debe tener al menos 6 caracteres.", ex.Message);
    }

    [Fact]
    public async Task Restablecer_con_un_correo_desconocido_da_el_mismo_error_que_un_codigo_malo()
    {
        var ex = await Assert.ThrowsAsync<ValidationException>(() => Restablecer("123456", c: "nadie@correo.co"));

        Assert.Equal("El código no es válido o ya venció. Pide uno nuevo.", ex.Message);
    }
}
