namespace Barberia.Application.DTOs.Barberos;

public class CreateBarberoRequest
{
    public string Nombre { get; set; } = string.Empty;

    public string Apellido { get; set; } = string.Empty;

    public string Telefono { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    public string? FotoUrl { get; set; }

    public string? Biografia { get; set; }

    public int AniosExperiencia { get; set; }

    public List<string> Especialidades { get; set; } = new();

    public List<Guid> ServicioIds { get; set; } = new();
}
