using Barberia.Domain.Enums;

namespace Barberia.Application.DTOs.Barberos;

public class SetHorarioRequest
{
    public Guid BarberoId { get; set; }

    public List<HorarioInput> Horarios { get; set; } = new();
}

public class HorarioInput
{
    public DiaSemana DiaSemana { get; set; }

    public TimeOnly HoraInicio { get; set; }

    public TimeOnly HoraFin { get; set; }

    public int IntervaloCitas { get; set; }
}
