using Barberia.Domain.Entities;

namespace Barberia.Application.Interfaces.Persistence;

public interface IAppointmentRepository
{
    Task<bool> HasOverlapAsync(Guid barberoId, DateTime startTimeUtc, DateTime endTimeUtc, CancellationToken cancellationToken);

    Task<Appointment> AddAsync(Appointment appointment, CancellationToken cancellationToken);

    Task<Appointment?> GetByIdAsync(Guid appointmentId, CancellationToken cancellationToken);

    Task<IReadOnlyList<Appointment>> GetByClienteAsync(Guid clienteId, CancellationToken cancellationToken);
}
