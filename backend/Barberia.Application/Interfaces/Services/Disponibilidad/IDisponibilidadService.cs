using Barberia.Application.DTOs.Disponibilidad;

namespace Barberia.Application.Interfaces.Services.Disponibilidad;

public interface IDisponibilidadService
{
    Task<DisponibilidadBarberoDto> GetSlotsDisponiblesAsync(
        Guid barberoId,
        Guid servicioId,
        DateOnly fecha,
        CancellationToken cancellationToken);
}
