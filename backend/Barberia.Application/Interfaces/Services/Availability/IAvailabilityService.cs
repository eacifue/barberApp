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

    /// <summary>Días libres de hoy en adelante (hora de Medellín), del más próximo al más lejano.</summary>
    Task<List<BarberDayOffDto>> GetDaysOffAsync(Guid barberId, CancellationToken cancellationToken);

    /// <summary>Quita un día libre del barbero.</summary>
    Task RemoveDayOffAsync(Guid barberId, Guid dayOffId, CancellationToken cancellationToken);
}
