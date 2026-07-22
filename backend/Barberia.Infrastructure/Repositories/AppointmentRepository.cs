using Barberia.Application.Interfaces.Persistence;
using Barberia.Domain.Entities;
using Barberia.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Barberia.Infrastructure.Repositories;

public class AppointmentRepository : IAppointmentRepository
{
    private readonly AppDbContext dbContext;
    private readonly ILogger<AppointmentRepository> logger;

    public AppointmentRepository(AppDbContext dbContext, ILogger<AppointmentRepository> logger)
    {
        this.dbContext = dbContext;
        this.logger = logger;
    }

    public async Task<Appointment> AddAsync(Appointment appointment, CancellationToken cancellationToken)
    {
        logger.LogDebug("Persistiendo cita {AppointmentId} para cliente {ClienteId}", appointment.Id, appointment.ClienteId);
        await dbContext.Appointments.AddAsync(appointment, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
        return appointment;
    }

    public Task<Appointment?> GetByIdAsync(Guid appointmentId, CancellationToken cancellationToken)
    {
        return dbContext.Appointments
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == appointmentId, cancellationToken);
    }

    public async Task<IReadOnlyList<Appointment>> GetByClienteAsync(Guid clienteId, CancellationToken cancellationToken)
    {
        var appointments = await dbContext.Appointments
            .AsNoTracking()
            .Where(x => x.ClienteId == clienteId)
            .OrderByDescending(x => x.StartTimeUtc)
            .ToListAsync(cancellationToken);

        logger.LogDebug("Se encontraron {Count} citas para cliente {ClienteId}", appointments.Count, clienteId);
        return appointments;
    }

    public Task<bool> HasOverlapAsync(Guid barberoId, DateTime startTimeUtc, DateTime endTimeUtc, CancellationToken cancellationToken)
    {
        return dbContext.Appointments
            .AsNoTracking()
            .AnyAsync(
                x => x.BarberoId == barberoId &&
                     x.StartTimeUtc < endTimeUtc &&
                     startTimeUtc < x.EndTimeUtc,
                cancellationToken);
    }
}
