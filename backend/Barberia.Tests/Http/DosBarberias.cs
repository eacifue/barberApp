using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using Barberia.Shared.Constants;
using BarberiaEntity = Barberia.Domain.Entities.Barberia;

namespace Barberia.Tests.Http;

/// <summary>Una barbería con una pieza de cada tipo; todo con ids nuevos por prueba.</summary>
public sealed record BarberiaSembrada(
    Guid Id,
    Cliente Admin,
    Cliente Cliente,
    Cliente CuentaBarbero,
    Barbero Barbero,
    Servicio Servicio,
    Cita Cita);

/// <summary>Dos barberías, A y B, que no deberían verse entre sí.</summary>
public sealed record DosBarberias(BarberiaSembrada A, BarberiaSembrada B)
{
    public static async Task<DosBarberias> CrearAsync(ApiFactory api) =>
        new(await SembrarAsync(api, "A"), await SembrarAsync(api, "B"));

    private static Task<BarberiaSembrada> SembrarAsync(ApiFactory api, string nombre) => api.ConBaseAsync(async db =>
    {
        var sufijo = Guid.NewGuid().ToString("N")[..8];
        var barberia = new BarberiaEntity { Nombre = $"Barbería {nombre} {sufijo}", Activa = true };
        var servicio = new Servicio { BarberiaId = barberia.Id, Nombre = $"Corte {nombre}", Descripcion = "", DuracionMinutos = 30, Precio = 35000 };
        var barbero = new Barbero { BarberiaId = barberia.Id, Nombre = $"Barbero {nombre}", Apellido = "X", Telefono = "", Correo = $"barbero{sufijo}@correo.co", Disponible = true };
        Cliente Cuenta(string rol, string correo, Guid? barberoId = null) => new()
        {
            BarberiaId = barberia.Id,
            Rol = rol,
            Nombre = $"{rol} {nombre}",
            Apellido = "X",
            Telefono = "",
            Correo = correo,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("secreta1"),
            BarberoId = barberoId,
        };
        var admin = Cuenta(Roles.AdminBarberia, $"admin{sufijo}@correo.co");
        var cliente = Cuenta(Roles.Cliente, $"cliente{sufijo}@correo.co");
        var cuentaBarbero = Cuenta(Roles.Barbero, $"cuenta.barbero{sufijo}@correo.co", barbero.Id);
        var cita = new Cita
        {
            BarberiaId = barberia.Id,
            ClienteId = cliente.Id,
            BarberoId = barbero.Id,
            ServicioId = servicio.Id,
            FechaCita = new DateOnly(2026, 12, 1),
            HoraInicio = new TimeOnly(10, 0),
            HoraFin = new TimeOnly(10, 30),
            Estado = EstadoCita.Pendiente,
            PrecioFinal = 35000,
        };

        db.Barberias.Add(barberia);
        db.AddRange(servicio, barbero, admin, cliente, cuentaBarbero, cita);
        db.BarberoServicios.Add(new BarberoServicio { BarberoId = barbero.Id, ServicioId = servicio.Id, Activo = true });
        await db.SaveChangesAsync();
        return new BarberiaSembrada(barberia.Id, admin, cliente, cuentaBarbero, barbero, servicio, cita);
    });
}
