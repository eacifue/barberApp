using System.Text.Json.Serialization;

namespace Barberia.Application.DTOs.Appointments;

public class CreateAppointmentRequest
{
    /// <summary>Id del cliente autenticado. Se sobrescribe desde el JWT en el controller.</summary>
    public Guid ClienteId { get; set; }

    /// <summary>Id del barbero. Acepta tanto "barberoId" como el alias "userId" que envía el frontend.</summary>
    [JsonPropertyName("barberoId")]
    public Guid BarberoId { get; set; }

    /// <summary>Alias de BarberoId para compatibilidad con clientes que envían "userId".</summary>
    [JsonPropertyName("userId")]
    public Guid? UserIdAlias
    {
        get => BarberoId == Guid.Empty ? null : BarberoId;
        set { if (value.HasValue && value.Value != Guid.Empty && BarberoId == Guid.Empty) BarberoId = value.Value; }
    }

    public string ServiceName { get; set; } = string.Empty;

    [JsonPropertyName("fullName")]
    public string FullName { get; set; } = string.Empty;

    [JsonPropertyName("identification")]
    public string Identification { get; set; } = string.Empty;

    [JsonPropertyName("phoneNumber")]
    public string PhoneNumber { get; set; } = string.Empty;

    public DateTime StartTimeUtc { get; set; }

    [JsonPropertyName("startDateTime")]
    public DateTime? StartDateTime { get; set; }

    public DateTime EndTimeUtc { get; set; }

    [JsonPropertyName("endDateTime")]
    public DateTime? EndDateTime { get; set; }

    public Guid ResolveClienteId() => ClienteId;

    public DateTime ResolveStartTimeUtc() => StartTimeUtc != default ? StartTimeUtc : StartDateTime ?? default;

    public DateTime ResolveEndTimeUtc() => EndTimeUtc != default ? EndTimeUtc : EndDateTime ?? default;
}
