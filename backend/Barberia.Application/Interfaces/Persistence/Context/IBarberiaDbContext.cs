using Barberia.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using BarberiaEntity = Barberia.Domain.Entities.Barberia;

namespace Barberia.Application.Interfaces.Persistence.Context;

public interface IBarberiaDbContext
{
    DbSet<BarberiaEntity> Barberias { get; }

    DbSet<Servicio> Servicios { get; }

    DbSet<Barbero> Barberos { get; }

    DbSet<BarberoServicio> BarberoServicios { get; }

    DbSet<HorarioSemana> HorariosSemana { get; }

    DbSet<BarberAvailability> BarberAvailabilities { get; }

    DbSet<BarberDayOff> BarberDaysOff { get; }

    DbSet<BloqueoHorario> BloqueosHorario { get; }

    DbSet<Cita> Citas { get; }

    DbSet<Cliente> Clientes { get; }

    DbSet<Review> Reviews { get; }

    DbSet<CodigoRecuperacion> CodigosRecuperacion { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
