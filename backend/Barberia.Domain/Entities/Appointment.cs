using Barberia.Domain.Enums;
using Barberia.Domain.Interfaces;

namespace Barberia.Domain.Entities;

public class Appointment : IAuditableEntity
{
    public Guid Id { get; set; }

    public Guid ClienteId { get; set; }

    public Guid BarberoId { get; set; }

    public string ServiceName { get; set; } = string.Empty;

    public string FullName { get; set; } = string.Empty;

    public string Identification { get; set; } = string.Empty;

    public string PhoneNumber { get; set; } = string.Empty;

    public DateTime StartTimeUtc { get; set; }

    public DateTime EndTimeUtc { get; set; }

    public AppointmentStatus Status { get; set; } = AppointmentStatus.Pendiente;

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAtUtc { get; set; }
}
