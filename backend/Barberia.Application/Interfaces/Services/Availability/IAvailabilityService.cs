using Barberia.Application.DTOs.Availability;

namespace Barberia.Application.Interfaces.Services.Availability;

public interface IAvailabilityService
{
    Task<List<BarberAvailabilityDto>> SetAvailabilityAsync(
        UpsertBarberAvailabilityRequest request,
        CancellationToken cancellationToken);

    Task<List<BarberAvailabilityDto>> GetAvailabilityAsync(
        Guid barberId,
        CancellationToken cancellationToken);

    Task<BarberDayOffDto> AddDayOffAsync(
        CreateBarberDayOffRequest request,
        CancellationToken cancellationToken);

    Task<List<BarberSlotDto>> GetAvailableSlotsAsync(
        Guid barberId,
        DateOnly date,
        CancellationToken cancellationToken);
}
