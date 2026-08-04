using Barberia.Application.DTOs.Servicios;

namespace Barberia.Application.DTOs.Barberos;

public class BarberoDto
{
    public Guid Id { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Apellido { get; set; } = string.Empty;

    public string Telefono { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    public string NombreCompleto => $"{Nombre} {Apellido}".Trim();

    public string? FotoUrl { get; set; }

    public string Biografia { get; set; } = string.Empty;

    public int AniosExperiencia { get; set; }

    public List<string> Especialidades { get; set; } = new();

    public decimal RatingPromedio { get; set; }

    public bool Disponible { get; set; }

    public bool Activo { get; set; }

    public List<ServicioDto> Servicios { get; set; } = new();
}
