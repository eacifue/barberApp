using Barberia.Domain.Common;
using Barberia.Domain.Enums;

namespace Barberia.Domain.Entities;

public class Servicio : BaseEntity
{
    public string Nombre { get; set; } = string.Empty;

    public string Descripcion { get; set; } = string.Empty;

    public TipoServicio Tipo { get; set; } = TipoServicio.Otro;

    public int DuracionMinutos { get; set; }

    public decimal Precio { get; set; }

    public string? FotoUrl { get; set; }

    public ICollection<Cita> Citas { get; set; } = new List<Cita>();

    public ICollection<BarberoServicio> BarberoServicios { get; set; } = new List<BarberoServicio>();
}
