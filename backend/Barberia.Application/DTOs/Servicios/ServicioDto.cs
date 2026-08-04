namespace Barberia.Application.DTOs.Servicios;

public class ServicioDto
{
    public Guid Id { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Descripcion { get; set; } = string.Empty;

    public string Tipo { get; set; } = string.Empty;

    public int DuracionMinutos { get; set; }

    public decimal Precio { get; set; }

    public string? FotoUrl { get; set; }

    public bool Activo { get; set; }
}
