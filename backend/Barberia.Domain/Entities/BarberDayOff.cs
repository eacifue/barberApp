using Barberia.Domain.Common;

namespace Barberia.Domain.Entities;

public class BarberDayOff : BaseEntity
{
    public Guid BarberId { get; set; }

    public DateOnly Date { get; set; }

    public string? Reason { get; set; }

    public Barbero Barber { get; set; } = null!;
}
