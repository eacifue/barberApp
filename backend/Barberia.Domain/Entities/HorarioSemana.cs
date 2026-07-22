using Barberia.Domain.Common;
using Barberia.Domain.Enums;

namespace Barberia.Domain.Entities;

public class HorarioSemana : BaseEntity
{
    public Guid BarberoId { get; set; }

    public DiaSemana DiaSemana { get; set; }

    public TimeOnly HoraInicio { get; set; }

    public TimeOnly HoraFin { get; set; }

    public int IntervaloCitasMinutos { get; set; } = 30;

    public Barbero Barbero { get; set; } = null!;
}
