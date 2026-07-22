namespace Barberia.Application.DTOs.Slots;

public class BloquearSlotRequest
{
    public Guid BarberoId { get; set; }

    public Guid ServicioId { get; set; }

    public DateOnly FechaCita { get; set; }

    public TimeOnly HoraInicio { get; set; }

    public Guid? ClienteId { get; set; }
}
