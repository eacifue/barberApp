using Barberia.Application.DTOs.Auth;
using Barberia.Application.DTOs.Barberos;
using Barberia.Application.DTOs.Clientes;
using Barberia.Application.DTOs.Servicios;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Interfaces.Services.Barberias;
using Barberia.Application.Services;
using Barberia.Application.Validators.Barberos;
using Barberia.Application.Validators.Clientes;
using Barberia.Application.Validators.Servicios;
using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using Barberia.Infrastructure.Data;
using Barberia.Tests.Gestion;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;

namespace Barberia.Tests.MultiBarberia;

// Todo lo que se crea queda en la barbería del contexto, nunca en otra.
public sealed class AsignacionBarberiaTests : GestionTestBase
{
    private sealed class FakeBarberiaContexto(Guid barberiaId) : IBarberiaContexto
    {
        public Task<Guid> ObtenerIdAsync(CancellationToken cancellationToken) => Task.FromResult(barberiaId);

        public Task<Guid?> ObtenerIdSiHayAsync(CancellationToken cancellationToken) => Task.FromResult<Guid?>(barberiaId);
    }

    private readonly Guid barberiaA = Guid.NewGuid();

    private IBarberiaContexto Contexto => new FakeBarberiaContexto(barberiaA);

    [Fact]
    public async Task Crear_un_servicio_lo_deja_en_la_barberia_del_contexto()
    {
        await using var context = NewContext();
        var service = new ServicioService(context, Mapper, new CreateServicioValidator(), Contexto);

        var dto = await service.CreateAsync(
            new CreateServicioRequest { Nombre = "Corte clásico", Descripcion = "Tijera y máquina.", Tipo = TipoServicio.Corte, DuracionMinutos = 30, Precio = 35000 },
            CancellationToken.None);

        await using var verify = NewContext();
        Assert.Equal(barberiaA, (await verify.Servicios.SingleAsync(x => x.Id == dto.Id)).BarberiaId);
    }

    private async Task<Guid> SembrarServicioAsync(Guid barberiaId)
    {
        await using var seed = NewContext();
        var servicio = new Servicio { BarberiaId = barberiaId, Nombre = "Corte clásico", DuracionMinutos = 30, Precio = 35000 };
        seed.Servicios.Add(servicio);
        await seed.SaveChangesAsync();
        return servicio.Id;
    }

    private BarberoService NuevoBarberoService(BarberiaDbContext context) =>
        new(context, Mapper, new CreateBarberoValidator(), null!, Contexto);

    private static CreateBarberoRequest Barbero(Guid servicioId) => new()
    {
        Nombre = "Julián",
        Apellido = "Restrepo",
        Telefono = "3011419610",
        Correo = "julian@correo.co",
        ServicioIds = [servicioId],
    };

    [Fact]
    public async Task Crear_un_barbero_lo_deja_en_la_barberia_del_contexto()
    {
        var servicioId = await SembrarServicioAsync(barberiaA);
        await using var context = NewContext();

        var dto = await NuevoBarberoService(context).CreateAsync(Barbero(servicioId), CancellationToken.None);

        await using var verify = NewContext();
        Assert.Equal(barberiaA, (await verify.Barberos.SingleAsync(x => x.Id == dto.Id)).BarberiaId);
    }

    [Fact]
    public async Task Un_barbero_no_puede_ofrecer_servicios_de_otra_barberia()
    {
        var servicioAjeno = await SembrarServicioAsync(Guid.NewGuid());
        await using var context = NewContext();

        await Assert.ThrowsAsync<ValidationException>(() => NuevoBarberoService(context).CreateAsync(Barbero(servicioAjeno), CancellationToken.None));

        await using var verify = NewContext();
        Assert.Empty(await verify.Barberos.ToListAsync());
    }

    private async Task<Guid> SembrarBarberoAsync(Guid barberiaId)
    {
        await using var seed = NewContext();
        var barbero = new Barbero { BarberiaId = barberiaId, Nombre = "Mateo", Apellido = "López", Telefono = "3000000000", Correo = "mateo@correo.co" };
        seed.Barberos.Add(barbero);
        await seed.SaveChangesAsync();
        return barbero.Id;
    }

    [Fact]
    public async Task Editar_un_barbero_no_le_asigna_servicios_de_otra_barberia()
    {
        var barberoId = await SembrarBarberoAsync(barberiaA);
        var servicioAjeno = await SembrarServicioAsync(Guid.NewGuid());
        await using var context = NewContext();

        await Assert.ThrowsAsync<ValidationException>(() => NuevoBarberoService(context).UpdateAsync(barberoId, Barbero(servicioAjeno), CancellationToken.None));
    }

    [Fact]
    public async Task Asignar_a_un_barbero_un_servicio_de_otra_barberia_es_rechazado()
    {
        var barberoId = await SembrarBarberoAsync(barberiaA);
        var servicioAjeno = await SembrarServicioAsync(Guid.NewGuid());
        await using var context = NewContext();

        await Assert.ThrowsAsync<ValidationException>(() => NuevoBarberoService(context).AsignarServicioAsync(barberoId, servicioAjeno, CancellationToken.None));

        await using var verify = NewContext();
        Assert.Empty(await verify.BarberoServicios.ToListAsync());
    }

    private sealed class FakeJwt : IJwtTokenGenerator
    {
        public string GenerateClienteToken(Cliente cliente) => "token";
    }

    private AuthService NuevoAuthService(BarberiaDbContext context) =>
        new(context, new FakeJwt(), new AdminUser(), null!, null!, NullLogger<AuthService>.Instance, Contexto);

    private static RegistroClienteRequest Registro(string correo) =>
        new() { Nombre = "Laura", Apellido = "Henao", Telefono = "3011419610", Correo = correo, Password = "secreta1" };

    private async Task SembrarClienteAsync(Guid? barberiaId, string correo)
    {
        await using var seed = NewContext();
        seed.Clientes.Add(new Cliente { BarberiaId = barberiaId, Nombre = "Otra", Apellido = "Persona", Correo = correo });
        await seed.SaveChangesAsync();
    }

    [Fact]
    public async Task Registrarse_deja_al_cliente_en_la_barberia_del_contexto()
    {
        await using var context = NewContext();

        await NuevoAuthService(context).RegistroAsync(Registro("laura@correo.co"), CancellationToken.None);

        await using var verify = NewContext();
        Assert.Equal(barberiaA, (await verify.Clientes.SingleAsync(x => x.Correo == "laura@correo.co")).BarberiaId);
    }

    [Fact]
    public async Task Un_correo_usado_en_otra_barberia_se_puede_registrar_en_esta()
    {
        await SembrarClienteAsync(Guid.NewGuid(), "laura@correo.co");
        await using var context = NewContext();

        await NuevoAuthService(context).RegistroAsync(Registro("Laura@Correo.co"), CancellationToken.None);

        await using var verify = NewContext();
        Assert.Equal(2, await verify.Clientes.CountAsync(x => x.Correo == "laura@correo.co"));
    }

    [Fact]
    public async Task Un_correo_usado_en_la_misma_barberia_se_rechaza()
    {
        await SembrarClienteAsync(barberiaA, "laura@correo.co");
        await using var context = NewContext();

        await Assert.ThrowsAsync<ConflictException>(() => NuevoAuthService(context).RegistroAsync(Registro("laura@correo.co"), CancellationToken.None));
    }

    private ClienteAdminService NuevoClienteAdminService(BarberiaDbContext context) =>
        new(context, Mapper, new CreateClienteAdminRequestValidator(), new UpdateClienteAdminRequestValidator(), Contexto);

    private static CreateClienteAdminRequest ClienteAdmin(string correo) =>
        new() { Nombre = "Kevin", Apellido = "Restrepo", Telefono = "3011419610", Correo = correo, Password = "secreta1" };

    [Fact]
    public async Task Crear_un_cliente_desde_el_admin_lo_deja_en_la_barberia_del_contexto()
    {
        await SembrarClienteAsync(Guid.NewGuid(), "kevin@correo.co");
        await using var context = NewContext();

        var dto = await NuevoClienteAdminService(context).CreateAsync(ClienteAdmin("kevin@correo.co"), CancellationToken.None);

        await using var verify = NewContext();
        Assert.Equal(barberiaA, (await verify.Clientes.SingleAsync(x => x.Id == dto.Id)).BarberiaId);
    }

    private async Task<Guid> SembrarCuentaAsync(Guid? barberiaId, string correo, string password, string rol = "Cliente")
    {
        await using var seed = NewContext();
        var cliente = new Cliente { BarberiaId = barberiaId, Rol = rol, Nombre = "Laura", Apellido = "Henao", Correo = correo, PasswordHash = BCrypt.Net.BCrypt.HashPassword(password) };
        seed.Clientes.Add(cliente);
        await seed.SaveChangesAsync();
        return cliente.Id;
    }

    [Fact]
    public async Task Con_el_mismo_correo_en_dos_barberias_el_login_entra_a_la_cuenta_de_esta()
    {
        await SembrarCuentaAsync(Guid.NewGuid(), "laura@correo.co", "ajena123");
        var propia = await SembrarCuentaAsync(barberiaA, "laura@correo.co", "propia123");
        await using var context = NewContext();

        var respuesta = await NuevoAuthService(context).LoginAsync(new LoginRequest { Correo = "laura@correo.co", Password = "propia123" }, CancellationToken.None);

        Assert.Equal(propia, respuesta.ClienteId);
    }

    [Fact]
    public async Task La_cuenta_de_otra_barberia_no_puede_entrar_a_esta()
    {
        await SembrarCuentaAsync(Guid.NewGuid(), "laura@correo.co", "ajena123");
        await using var context = NewContext();

        await Assert.ThrowsAsync<UnauthorizedException>(() => NuevoAuthService(context).LoginAsync(new LoginRequest { Correo = "laura@correo.co", Password = "ajena123" }, CancellationToken.None));
    }

    [Fact]
    public async Task El_superadmin_entra_aunque_no_pertenezca_a_ninguna_barberia()
    {
        var admin = await SembrarCuentaAsync(null, "admin@barberia.local", "Admin123!", "Admin");
        await using var context = NewContext();

        var respuesta = await NuevoAuthService(context).LoginAsync(new LoginRequest { Correo = "admin@barberia.local", Password = "Admin123!" }, CancellationToken.None);

        Assert.Equal(admin, respuesta.ClienteId);
    }

    [Fact]
    public async Task Editar_un_cliente_con_un_correo_de_otra_barberia_esta_permitido()
    {
        await SembrarCuentaAsync(Guid.NewGuid(), "kevin@correo.co", "x123456");
        var id = await SembrarCuentaAsync(barberiaA, "laura@correo.co", "x123456");
        await using var context = NewContext();

        await NuevoClienteAdminService(context).UpdateAsync(
            id,
            new UpdateClienteAdminRequest { Nombre = "Laura", Apellido = "Henao", Telefono = "3011419610", Correo = "kevin@correo.co" },
            CancellationToken.None);

        await using var verify = NewContext();
        Assert.Equal("kevin@correo.co", (await verify.Clientes.SingleAsync(x => x.Id == id)).Correo);
    }
}
