namespace Barberia.Application.DTOs.Slots;

public sealed class LiberarReservaRequest
{
    public Guid BarberoId { get; set; }

    public DateOnly FechaCita { get; set; }

    public TimeOnly HoraInicio { get; set; }
}
