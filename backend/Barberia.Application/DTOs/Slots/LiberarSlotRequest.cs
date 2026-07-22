namespace Barberia.Application.DTOs.Slots;

public class LiberarSlotRequest
{
    public string TokenBloqueo { get; set; } = string.Empty;

    public Guid BarberoId { get; set; }

    public DateOnly FechaCita { get; set; }

    public TimeOnly HoraInicio { get; set; }
}
