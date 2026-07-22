using Barberia.Domain.Common;

namespace Barberia.Domain.Entities;

public class BarberAvailability : BaseEntity
{
    public Guid BarberId { get; set; }

    public DayOfWeek DayOfWeek { get; set; }

    public TimeSpan StartTime { get; set; }

    public TimeSpan EndTime { get; set; }

    public bool IsActive { get; set; } = true;

    public Barbero Barber { get; set; } = null!;
}
