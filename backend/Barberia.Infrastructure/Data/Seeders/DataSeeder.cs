using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using BarberiaEntity = Barberia.Domain.Entities.Barberia;

namespace Barberia.Infrastructure.Data.Seeders;

public static class DataSeeder
{
    public static async Task SeedAsync(
        BarberiaDbContext context,
        IConfiguration? configuration = null,
        bool isDevelopment = false,
        ILogger? logger = null,
        CancellationToken cancellationToken = default)
    {
        // Verificar que las migraciones pendientes hayan sido aplicadas
        var pendingMigrations = await context.Database.GetPendingMigrationsAsync(cancellationToken);
        if (pendingMigrations.Any())
        {
            throw new InvalidOperationException(
                $"Hay {pendingMigrations.Count()} migración(es) pendiente(s). Ejecuta MigrateAsync() antes del Seeder.");
        }

        await EnsureAdminUserAsync(context, configuration, isDevelopment, logger, cancellationToken);

        if (await context.Barberias.AnyAsync(cancellationToken))
        {
            return;
        }

        var barberia = new BarberiaEntity
        {
            Nombre = "BarberShop Medellin",
            Descripcion = "Barberia urbana con enfoque en experiencia premium.",
            Slogan = "Estilo que habla por ti",
            Telefono = "+57 3000000000",
            Correo = "contacto@barbershopmedellin.com",
            SitioWeb = "https://barbershopmedellin.com",
            Direccion = "Calle 10 #43A-22",
            Ciudad = "Medellin",
            Departamento = "Antioquia",
            Pais = "Colombia",
            Latitud = 6.2088m,
            Longitud = -75.5658m,
            FotoPortada = "https://cdn.barbershopmedellin.com/portada.jpg",
            HoraApertura = new TimeOnly(9, 0),
            HoraCierre = new TimeOnly(18, 0),
            DiasDescanso = new List<DiaSemana> { DiaSemana.Domingo },
            Activa = true
        };

        var servicios = new List<Servicio>
        {
            new()
            {
                Nombre = "Corte",
                Descripcion = "Corte clasico o moderno personalizado.",
                Tipo = TipoServicio.Corte,
                DuracionMinutos = 45,
                Precio = 25000
            },
            new()
            {
                Nombre = "Barba",
                Descripcion = "Perfilado y cuidado profesional de barba.",
                Tipo = TipoServicio.Barba,
                DuracionMinutos = 30,
                Precio = 15000
            },
            new()
            {
                Nombre = "Combo",
                Descripcion = "Corte + barba con atencion integral.",
                Tipo = TipoServicio.Combo,
                DuracionMinutos = 60,
                Precio = 35000
            },
            new()
            {
                Nombre = "Tinte",
                Descripcion = "Coloracion profesional para cabello.",
                Tipo = TipoServicio.Tinte,
                DuracionMinutos = 90,
                Precio = 50000
            },
            new()
            {
                Nombre = "Afeitado",
                Descripcion = "Afeitado al ras con toalla caliente.",
                Tipo = TipoServicio.Afeitado,
                DuracionMinutos = 35,
                Precio = 20000
            }
        };

        var barberos = new List<Barbero>
        {
            new()
            {
                Nombre = "Santiago",
                Apellido = "Restrepo",
                Telefono = "+57 3011111111",
                Correo = "santiago@barbershopmedellin.com",
                Biografia = "Especialista en cortes degradados y estilo urbano.",
                AniosExperiencia = 7,
                Especialidades = new List<string> { "Fade", "Corte clasico", "Barba" },
                Disponible = true,
                RatingPromedio = 4.8m
            },
            new()
            {
                Nombre = "Andres",
                Apellido = "Gomez",
                Telefono = "+57 3022222222",
                Correo = "andres@barbershopmedellin.com",
                Biografia = "Experto en afeitado tradicional y cuidado de barba.",
                AniosExperiencia = 9,
                Especialidades = new List<string> { "Afeitado", "Barba", "Tratamientos" },
                Disponible = true,
                RatingPromedio = 4.7m
            },
            new()
            {
                Nombre = "Mateo",
                Apellido = "Lopez",
                Telefono = "+57 3033333333",
                Correo = "mateo@barbershopmedellin.com",
                Biografia = "Colorista y estilista de tendencias modernas.",
                AniosExperiencia = 5,
                Especialidades = new List<string> { "Tinte", "Corte moderno", "Combo" },
                Disponible = true,
                RatingPromedio = 4.9m
            }
        };

        var diasLaborales = new[]
        {
            DiaSemana.Lunes,
            DiaSemana.Martes,
            DiaSemana.Miercoles,
            DiaSemana.Jueves,
            DiaSemana.Viernes,
            DiaSemana.Sabado
        };

        var horarios = new List<HorarioSemana>();
        foreach (var barbero in barberos)
        {
            foreach (var dia in diasLaborales)
            {
                horarios.Add(new HorarioSemana
                {
                    Barbero = barbero,
                    DiaSemana = dia,
                    HoraInicio = new TimeOnly(9, 0),
                    HoraFin = new TimeOnly(18, 0),
                    IntervaloCitasMinutos = 30
                });
            }
        }

        var barberoServicios = new List<BarberoServicio>();
        foreach (var barbero in barberos)
        {
            foreach (var servicio in servicios)
            {
                barberoServicios.Add(new BarberoServicio
                {
                    Barbero = barbero,
                    Servicio = servicio,
                    PrecioEspecial = null,
                    Activo = true
                });
            }
        }

        await context.Barberias.AddAsync(barberia, cancellationToken);
        await context.Servicios.AddRangeAsync(servicios, cancellationToken);
        await context.Barberos.AddRangeAsync(barberos, cancellationToken);
        await context.HorariosSemana.AddRangeAsync(horarios, cancellationToken);
        await context.BarberoServicios.AddRangeAsync(barberoServicios, cancellationToken);

        await context.SaveChangesAsync(cancellationToken);
    }

    private static async Task EnsureAdminUserAsync(
        BarberiaDbContext context,
        IConfiguration? configuration,
        bool isDevelopment,
        ILogger? logger,
        CancellationToken cancellationToken)
    {
        var existingAdmin = await context.Clientes
            .AsNoTracking()
            .Where(x => x.Activo && x.Rol == "Admin")
            .Select(x => new { x.Id, x.Correo })
            .FirstOrDefaultAsync(cancellationToken);

        if (existingAdmin is not null)
        {
            return;
        }

        var email = configuration?["SeedAdmin:Email"];
        var password = configuration?["SeedAdmin:Password"];
        var nombre = configuration?["SeedAdmin:Nombre"] ?? "Admin";
        var apellido = configuration?["SeedAdmin:Apellido"] ?? "Sistema";
        var telefono = configuration?["SeedAdmin:Telefono"] ?? "+57 3000000000";

        // En dev, si no configuran credenciales, usamos un default seguro para poder entrar al panel.
        if (isDevelopment)
        {
            email ??= "admin@barberia.local";
            password ??= "Admin123!";
        }

        if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
        {
            logger?.LogWarning(
                "No se creó usuario Admin por falta de configuración. Define SeedAdmin:Email y SeedAdmin:Password (o habilita Development para defaults)."
            );
            return;
        }

        email = email.Trim().ToLowerInvariant();

        var existsByEmail = await context.Clientes
            .AnyAsync(x => x.Correo == email, cancellationToken);

        if (existsByEmail)
        {
            logger?.LogWarning(
                "No se creó usuario Admin porque ya existe un cliente con el correo {Email}. Asigna Rol='Admin' manualmente si corresponde.",
                email);
            return;
        }

        var admin = new Cliente
        {
            Rol = "Admin",
            Nombre = nombre.Trim(),
            Apellido = apellido.Trim(),
            Telefono = telefono.Trim(),
            Correo = email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
            Activo = true
        };

        await context.Clientes.AddAsync(admin, cancellationToken);
        await context.SaveChangesAsync(cancellationToken);

        logger?.LogInformation("Usuario Admin creado por seeder con correo {Email}", email);
    }
}
