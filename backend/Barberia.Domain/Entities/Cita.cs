using Barberia.Domain.Common;
using Barberia.Domain.Enums;

namespace Barberia.Domain.Entities;

public class Cita : BaseEntity
{
    public Guid ClienteId { get; set; }

    public Guid BarberoId { get; set; }

    public Guid ServicioId { get; set; }

    public DateOnly FechaCita { get; set; }

    public TimeOnly HoraInicio { get; set; }

    public TimeOnly HoraFin { get; set; }

    public EstadoCita Estado { get; set; } = EstadoCita.Pendiente;

    public string? Notas { get; set; }

    public decimal PrecioFinal { get; set; }

    public string? TokenRedisBloqueo { get; set; }

    public Cliente Cliente { get; set; } = null!;

    public Barbero Barbero { get; set; } = null!;

    public Servicio Servicio { get; set; } = null!;

    public Review? Review { get; set; }
}
