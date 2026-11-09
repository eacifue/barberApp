using AutoMapper;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Mappings.Barberia;
using Barberia.Application.Services;
using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using Barberia.Infrastructure.Data;
using Barberia.Shared.Constants;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Time.Testing;

namespace Barberia.Tests.Citas;

// Base de las pruebas de CitaService sobre EF Core InMemory: cubre reglas de
// negocio independientes del proveedor. No prueba restricciones relacionales.
public abstract class CitaServiceTestBase
{
    protected sealed class FakeCurrentUser(Guid clienteId, Guid barberiaId) : ICurrentUserService
    {
        public Guid? UserId => clienteId;
        public Guid? ClienteId => clienteId;
        public string Role => Roles.Cliente;
        public bool IsAuthenticated => true;
        public bool IsAdmin => false;
        public bool IsAdminBarberia => false;
        public bool IsBarbero => false;
        public bool IsCliente => true;
        public Guid? BarberoId => null;
        public Guid? BarberiaId => barberiaId;
        public bool VeTodasLasBarberias => false;
    }

    /// <summary>
    /// Reloj controlado (UTC). Arranca el 28 oct 2026 a las 5:00 a. m. en Medellín
    /// (antes de la cita sembrada); cada prueba lo adelanta, nunca lo retrocede.
    /// </summary>
    protected readonly FakeTimeProvider Clock = new(new DateTimeOffset(2026, 10, 28, 10, 0, 0, TimeSpan.Zero));

    protected readonly FakeNotificationService Notifications = new();

    protected readonly string databaseName = Guid.NewGuid().ToString();
    protected readonly Guid clienteId = Guid.NewGuid();
    protected readonly Guid otroClienteId = Guid.NewGuid();
    protected readonly Guid barberoId = Guid.NewGuid();
    protected readonly Guid servicioId = Guid.NewGuid();
    protected readonly Guid barberiaId = Guid.NewGuid();

    protected BarberiaDbContext NewContext(Guid currentClienteId) =>
        new(new DbContextOptionsBuilder<BarberiaDbContext>().UseInMemoryDatabase(databaseName).Options,
            new FakeCurrentUser(currentClienteId, barberiaId));

    protected CitaService NewService(BarberiaDbContext context, Guid currentClienteId)
    {
        var mapper = new MapperConfiguration(cfg => cfg.AddMaps(typeof(CitaProfile).Assembly)).CreateMapper();
        // Estas reglas no usan bloqueos de slots ni el validador de creación.
        return new CitaService(context, null!, Notifications, new FakeCurrentUser(currentClienteId, barberiaId), null!, mapper, Clock);
    }

    protected async Task<Guid> SeedCitaAsync(EstadoCita estado, Guid? owner = null)
    {
        await using var context = NewContext(clienteId);
        if (!await context.Barberos.IgnoreQueryFilters().AnyAsync(x => x.Id == barberoId))
        {
            context.Clientes.Add(new Cliente { Id = clienteId, BarberiaId = barberiaId, Nombre = "Andrés", Apellido = "Gómez", Correo = "andres@correo.co" });
            context.Clientes.Add(new Cliente { Id = otroClienteId, BarberiaId = barberiaId, Nombre = "Laura", Apellido = "Henao", Correo = "laura@correo.co" });
            context.Barberos.Add(new Barbero { Id = barberoId, BarberiaId = barberiaId, Nombre = "Julián", Apellido = "Restrepo" });
            context.Servicios.Add(new Servicio { Id = servicioId, BarberiaId = barberiaId, Nombre = "Corte clásico", DuracionMinutos = 30, Precio = 35000 });
        }

        var cita = new Cita
        {
            BarberiaId = barberiaId,
            ClienteId = owner ?? clienteId,
            BarberoId = barberoId,
            ServicioId = servicioId,
            FechaCita = new DateOnly(2026, 10, 28),
            HoraInicio = new TimeOnly(18, 0),
            HoraFin = new TimeOnly(18, 30),
            PrecioFinal = 35000,
            Estado = estado,
        };
        context.Citas.Add(cita);
        await context.SaveChangesAsync();
        return cita.Id;
    }

}
