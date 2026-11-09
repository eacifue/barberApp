using Barberia.Domain.Entities;
using Barberia.Infrastructure.Data;
using Barberia.Tests.Gestion;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql;
using Testcontainers.PostgreSql;
using BarberiaEntity = Barberia.Domain.Entities.Barberia;

namespace Barberia.Tests.MultiBarberia;

/// <summary>Un Postgres real (el mismo de docker-compose) para toda la clase; cada prueba usa su propia base.</summary>
public sealed class PostgresFixture : IAsyncLifetime
{
    private readonly PostgreSqlContainer container = new PostgreSqlBuilder().WithImage("postgres:17-alpine").Build();

    public Task InitializeAsync() => container.StartAsync();

    public Task DisposeAsync() => container.DisposeAsync().AsTask();

    public string NuevaBase() =>
        new NpgsqlConnectionStringBuilder(container.GetConnectionString()) { Database = "t" + Guid.NewGuid().ToString("N") }.ConnectionString;
}

// Reglas que solo garantiza la base de datos (índices, CHECK, llaves) y el
// llenado de la migración AddBarberiaIdMultiBarberia sobre datos existentes.
// EF InMemory no las aplica, por eso van contra Postgres.
public sealed class MigracionMultiBarberiaTests(PostgresFixture postgres) : IClassFixture<PostgresFixture>
{
    private const string MigracionAnterior = "20261107220519_AddCodigosRecuperacion";

    private readonly string conexion = postgres.NuevaBase();

    private BarberiaDbContext NewContext() =>
        new(new DbContextOptionsBuilder<BarberiaDbContext>().UseNpgsql(conexion).Options, new GestionUser());

    /// <summary>Usuario Admin: los filtros por rol no esconden nada en estas pruebas.</summary>
    private sealed class GestionUser : Application.Interfaces.Services.ICurrentUserService
    {
        public Guid? UserId => null;
        public Guid? ClienteId => null;
        public string Role => Shared.Constants.Roles.Admin;
        public bool IsAuthenticated => true;
        public bool IsAdmin => true;
        public bool IsAdminBarberia => false;
        public bool IsBarbero => false;
        public bool IsCliente => false;
        public Guid? BarberoId => null;
        public Guid? BarberiaId => null;
        public bool VeTodasLasBarberias => true;
    }

    private async Task MigrarAsync(string? hasta = null)
    {
        await using var context = NewContext();
        await context.GetService<IMigrator>().MigrateAsync(hasta);
    }

    private async Task SqlAsync(string sql)
    {
        await using var context = NewContext();
        await context.Database.ExecuteSqlRawAsync(sql);
    }

    private static string InsertBarberia(Guid id, string creada) => $"""
        INSERT INTO barberias ("Id","Nombre","Descripcion","Slogan","Telefono","Correo","SitioWeb","Direccion","Ciudad","Departamento","Latitud","Longitud","FotoPortada","HoraApertura","HoraCierre","DiasDescanso","Activa","CreatedAt","UpdatedAt","Activo")
        VALUES ('{id}','B','','','','','','','','',0,0,'','09:00','19:00','[]',true,'{creada}','{creada}',true);
        """;

    [Fact]
    public async Task La_migracion_deja_los_datos_existentes_en_la_barberia_original_y_al_superadmin_sin_barberia()
    {
        await MigrarAsync(MigracionAnterior);
        Guid original = Guid.NewGuid(), posterior = Guid.NewGuid();
        Guid servicio = Guid.NewGuid(), barbero = Guid.NewGuid(), cliente = Guid.NewGuid(), admin = Guid.NewGuid(), cita = Guid.NewGuid();
        await SqlAsync(InsertBarberia(posterior, "2026-06-01") + InsertBarberia(original, "2026-01-01") + $"""
            INSERT INTO servicios ("Id","Nombre","Descripcion","Tipo","DuracionMinutos","Precio","CreatedAt","UpdatedAt","Activo")
            VALUES ('{servicio}','Corte','','Corte',30,35000,now(),now(),true);
            INSERT INTO barberos ("Id","Nombre","Apellido","Telefono","Correo","Biografia","AniosExperiencia","Especialidades","Disponible","RatingPromedio","CreatedAt","UpdatedAt","Activo")
            VALUES ('{barbero}','Julián','Restrepo','','j@correo.co','',1,'[]',true,0,now(),now(),true);
            INSERT INTO clientes ("Id","Rol","Nombre","Apellido","Telefono","Correo","PasswordHash","TotalCitas","CreatedAt","UpdatedAt","Activo")
            VALUES ('{cliente}','Cliente','Laura','Henao','','laura@correo.co','x',0,now(),now(),true),
                   ('{admin}','Admin','Admin','Sistema','','admin@barberia.local','x',0,now(),now(),true);
            INSERT INTO citas ("Id","ClienteId","BarberoId","ServicioId","FechaCita","HoraInicio","HoraFin","Estado","PrecioFinal","CreatedAt","UpdatedAt","Activo")
            VALUES ('{cita}','{cliente}','{barbero}','{servicio}','2026-11-10','10:00','10:30','Pendiente',35000,now(),now(),true);
            """);

        await MigrarAsync();

        await using var context = NewContext();
        Assert.Equal(original, (await context.Servicios.SingleAsync(x => x.Id == servicio)).BarberiaId);
        Assert.Equal(original, (await context.Barberos.SingleAsync(x => x.Id == barbero)).BarberiaId);
        Assert.Equal(original, (await context.Clientes.SingleAsync(x => x.Id == cliente)).BarberiaId);
        Assert.Equal(original, (await context.Citas.SingleAsync(x => x.Id == cita)).BarberiaId);
        Assert.Null((await context.Clientes.SingleAsync(x => x.Id == admin)).BarberiaId);
    }

    [Fact]
    public async Task Con_datos_y_sin_ninguna_barberia_la_migracion_falla_con_un_mensaje_claro()
    {
        await MigrarAsync(MigracionAnterior);
        await SqlAsync("""
            INSERT INTO servicios ("Id","Nombre","Descripcion","Tipo","DuracionMinutos","Precio","CreatedAt","UpdatedAt","Activo")
            VALUES (gen_random_uuid(),'Corte','','Corte',30,35000,now(),now(),true);
            """);

        var ex = await Assert.ThrowsAsync<PostgresException>(() => MigrarAsync());

        Assert.Contains("No hay ninguna barbería", ex.MessageText);
    }

    private async Task<(Guid A, Guid B)> BaseConDosBarberiasAsync()
    {
        await MigrarAsync();
        var a = new BarberiaEntity { Nombre = "A" };
        var b = new BarberiaEntity { Nombre = "B" };
        await using var context = NewContext();
        context.Barberias.AddRange(a, b);
        await context.SaveChangesAsync();
        return (a.Id, b.Id);
    }

    private static Cliente Persona(Guid? barberiaId, string correo, string rol = "Cliente") =>
        new() { BarberiaId = barberiaId, Rol = rol, Nombre = "Laura", Apellido = "Henao", Telefono = "", Correo = correo, PasswordHash = "x" };

    private async Task GuardarAsync(params Cliente[] clientes)
    {
        await using var context = NewContext();
        context.Clientes.AddRange(clientes);
        await context.SaveChangesAsync();
    }

    [Fact]
    public async Task El_mismo_correo_puede_estar_en_dos_barberias()
    {
        var (a, b) = await BaseConDosBarberiasAsync();

        await GuardarAsync(Persona(a, "laura@correo.co"), Persona(b, "laura@correo.co"));

        await using var context = NewContext();
        Assert.Equal(2, await context.Clientes.CountAsync(x => x.Correo == "laura@correo.co"));
    }

    [Fact]
    public async Task El_mismo_correo_no_puede_repetirse_dentro_de_una_barberia()
    {
        var (a, _) = await BaseConDosBarberiasAsync();
        await GuardarAsync(Persona(a, "laura@correo.co"));

        await Assert.ThrowsAsync<DbUpdateException>(() => GuardarAsync(Persona(a, "laura@correo.co")));
    }

    [Fact]
    public async Task Solo_el_superadmin_puede_quedar_sin_barberia()
    {
        var (a, _) = await BaseConDosBarberiasAsync();

        await GuardarAsync(Persona(null, "admin@barberia.local", "Admin"));
        await Assert.ThrowsAsync<DbUpdateException>(() => GuardarAsync(Persona(null, "laura@correo.co")));
        await Assert.ThrowsAsync<DbUpdateException>(() => GuardarAsync(Persona(a, "otro.admin@correo.co", "Admin")));
    }

    [Fact]
    public async Task No_se_puede_borrar_una_barberia_que_tiene_datos()
    {
        var (a, _) = await BaseConDosBarberiasAsync();
        await GuardarAsync(Persona(a, "laura@correo.co"));

        await Assert.ThrowsAsync<PostgresException>(() => SqlAsync($"""DELETE FROM barberias WHERE "Id" = '{a}';"""));
    }
}
