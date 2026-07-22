namespace Barberia.Application.DTOs.Disponibilidad;

public class SlotDisponibleDto
{
    public DateOnly FechaCita { get; set; }

    public TimeOnly HoraInicio { get; set; }

    public TimeOnly HoraFin { get; set; }

    public bool Disponible { get; set; }

    public bool BloqueadoPorRedis { get; set; }

    public int? MinutosRestantesBloqueo { get; set; }
}
