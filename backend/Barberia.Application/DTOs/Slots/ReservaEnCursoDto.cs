namespace Barberia.Application.DTOs.Slots;

/// <summary>Reserva en curso para el panel: quién está apartando qué horario y cuándo se libera.</summary>
public sealed class ReservaEnCursoDto
{
    public Guid BarberoId { get; init; }

    public string BarberoNombre { get; init; } = string.Empty;

    public Guid ClienteId { get; init; }

    public string ClienteNombre { get; init; } = string.Empty;

    public DateOnly FechaCita { get; init; }

    public TimeOnly HoraInicio { get; init; }

    public DateTime BloqueadoEn { get; init; }

    public DateTime ExpiraEn { get; init; }

    public int SegundosRestantes { get; init; }
}
