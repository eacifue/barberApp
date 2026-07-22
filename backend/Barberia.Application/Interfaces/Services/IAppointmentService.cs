using Barberia.Application.DTOs.Appointments;

namespace Barberia.Application.Interfaces.Services;

public interface IAppointmentService
{
    Task<AppointmentResponse> CreateAsync(CreateAppointmentRequest request, CancellationToken cancellationToken);

    Task<AppointmentResponse> GetByIdAsync(Guid appointmentId, CancellationToken cancellationToken);

    Task<IReadOnlyList<AppointmentResponse>> GetByClienteAsync(Guid clienteId, CancellationToken cancellationToken);
}
