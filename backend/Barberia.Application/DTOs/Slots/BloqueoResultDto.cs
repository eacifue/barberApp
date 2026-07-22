namespace Barberia.Application.DTOs.Slots;

public class BloqueoResultDto
{
    public bool Exitoso { get; set; }

    public string? TokenBloqueo { get; set; }

    public string? MensajeError { get; set; }

    public int ExpiresInSeconds { get; set; }

    public string Mensaje { get; set; } = string.Empty;
}
