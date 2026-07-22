namespace Barberia.Application.DTOs.Barberos;

public class HorarioSemanaDto
{
    public Guid Id { get; set; }

    public Guid BarberoId { get; set; }

    public string DiaSemana { get; set; } = string.Empty;

    public TimeOnly HoraInicio { get; set; }

    public TimeOnly HoraFin { get; set; }

    public int IntervaloCitasMinutos { get; set; }
}
