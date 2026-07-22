namespace Barberia.Application.DTOs.Availability;

public class UpsertBarberAvailabilityRequest
{
    public Guid BarberId { get; set; }

    public List<BarberAvailabilityInput> Availability { get; set; } = new();
}

public class BarberAvailabilityInput
{
    public DayOfWeek DayOfWeek { get; set; }

    public TimeSpan? StartTime { get; set; }

    public TimeSpan? EndTime { get; set; }

    public bool IsActive { get; set; } = true;
}

public class BarberAvailabilityDto
{
    public Guid Id { get; set; }

    public Guid BarberId { get; set; }

    public DayOfWeek DayOfWeek { get; set; }

    public TimeSpan StartTime { get; set; }

    public TimeSpan EndTime { get; set; }

    public bool IsActive { get; set; }
}

public class CreateBarberDayOffRequest
{
    public Guid BarberId { get; set; }

    public DateOnly Date { get; set; }

    public string? Reason { get; set; }
}

public class BarberDayOffDto
{
    public Guid Id { get; set; }

    public Guid BarberId { get; set; }

    public DateOnly Date { get; set; }

    public string? Reason { get; set; }
}

public class BarberSlotDto
{
    public TimeOnly StartTime { get; set; }

    public TimeOnly EndTime { get; set; }

    public bool Available { get; set; }
}
