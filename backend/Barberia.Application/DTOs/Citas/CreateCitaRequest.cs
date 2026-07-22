namespace Barberia.Application.DTOs.Citas;

public class CreateCitaRequest
{
    public Guid ClienteId { get; set; }

    public Guid BarberoId { get; set; }

    public Guid ServicioId { get; set; }

    public DateOnly FechaCita { get; set; }

    public TimeOnly HoraInicio { get; set; }

    public string TokenRedisBloqueo { get; set; } = string.Empty;
}
