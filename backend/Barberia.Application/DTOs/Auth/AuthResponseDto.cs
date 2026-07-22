namespace Barberia.Application.DTOs.Auth;

public class AuthResponseDto
{
    public string Token { get; set; } = string.Empty;

    public Guid ClienteId { get; set; }

    public string Correo { get; set; } = string.Empty;

    public string Rol { get; set; } = string.Empty;

    public string NombreCompleto { get; set; } = string.Empty;

    public Guid? BarberiaId { get; set; }

    public Guid? BarberoId { get; set; }
}
