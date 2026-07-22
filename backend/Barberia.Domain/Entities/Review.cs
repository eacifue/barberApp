using Barberia.Domain.Common;

namespace Barberia.Domain.Entities;

public class Review : BaseEntity
{
    public Guid ClienteId { get; set; }

    public Guid BarberoId { get; set; }

    public Guid CitaId { get; set; }

    public int Calificacion { get; set; }

    public string? Comentario { get; set; }

    public bool Visible { get; set; } = true;

    public Cliente Cliente { get; set; } = null!;

    public Barbero Barbero { get; set; } = null!;

    public Cita Cita { get; set; } = null!;
}
