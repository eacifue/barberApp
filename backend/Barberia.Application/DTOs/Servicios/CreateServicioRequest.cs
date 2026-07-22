using Barberia.Domain.Enums;

namespace Barberia.Application.DTOs.Servicios;

public class CreateServicioRequest
{
    public Guid BarberiaId { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Descripcion { get; set; } = string.Empty;

    public TipoServicio Tipo { get; set; }

    public int DuracionMinutos { get; set; }

    public decimal Precio { get; set; }

    public string? FotoUrl { get; set; }
}
