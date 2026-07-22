namespace Barberia.Domain.Entities;

public class BarberoServicio
{
    public Guid BarberoId { get; set; }

    public Guid ServicioId { get; set; }

    public decimal? PrecioEspecial { get; set; }

    public bool Activo { get; set; } = true;

    public Barbero Barbero { get; set; } = null!;

    public Servicio Servicio { get; set; } = null!;
}
