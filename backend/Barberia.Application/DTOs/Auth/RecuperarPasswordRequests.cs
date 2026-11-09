namespace Barberia.Application.DTOs.Auth;

public sealed class SolicitarCodigoRequest
{
    public string Correo { get; set; } = string.Empty;
}

public sealed class RestablecerPasswordRequest
{
    public string Correo { get; set; } = string.Empty;

    public string Codigo { get; set; } = string.Empty;

    public string NuevaPassword { get; set; } = string.Empty;
}
