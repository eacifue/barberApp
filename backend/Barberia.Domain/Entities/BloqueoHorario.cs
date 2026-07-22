using Barberia.Domain.Common;

namespace Barberia.Domain.Entities;

public class BloqueoHorario : BaseEntity
{
    public Guid BarberoId { get; set; }

    public DateTime FechaInicio { get; set; }

    public DateTime FechaFin { get; set; }

    public string Motivo { get; set; } = string.Empty;

    public Barbero Barbero { get; set; } = null!;
}
