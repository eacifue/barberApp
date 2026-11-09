using AutoMapper;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Mappings.Barberia;
using Barberia.Infrastructure.Data;
using Barberia.Shared.Constants;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Time.Testing;

namespace Barberia.Tests.Gestion;

// Base de las pruebas de Gestión (panel) sobre EF Core InMemory, con un
// administrador autenticado. No prueba restricciones relacionales.
public abstract class GestionTestBase
{
    protected sealed class AdminUser : ICurrentUserService
    {
        public Guid? UserId { get; } = Guid.NewGuid();
        public Guid? ClienteId => UserId;
        public string Role => Roles.Admin;
        public bool IsAuthenticated => true;
        public bool IsAdmin => true;
        public bool IsAdminBarberia => false;
        public bool IsBarbero => false;
        public bool IsCliente => false;
        public Guid? BarberoId => null;
    }

    private readonly string databaseName = Guid.NewGuid().ToString();

    /// <summary>Reloj controlado (UTC). Arranca el 7 nov 2026 a las 9:00 a. m. en Medellín.</summary>
    protected readonly FakeTimeProvider Clock = new(new DateTimeOffset(2026, 11, 7, 14, 0, 0, TimeSpan.Zero));

    protected static readonly IMapper Mapper = new MapperConfiguration(cfg => cfg.AddMaps(typeof(CitaProfile).Assembly)).CreateMapper();

    protected BarberiaDbContext NewContext() =>
        new(new DbContextOptionsBuilder<BarberiaDbContext>().UseInMemoryDatabase(databaseName).Options, new AdminUser());
}
