namespace Barberia.Application.DTOs.Appointments;

public class AppointmentResponse
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

    public string Status { get; set; } = string.Empty;
}
