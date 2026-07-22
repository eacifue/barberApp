using Barberia.Domain.Common;

namespace Barberia.Domain.Entities;

public class Barbero : BaseEntity
{
    public Guid BarberiaId { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Apellido { get; set; } = string.Empty;

    public string Telefono { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    public string? FotoUrl { get; set; }

    public string Biografia { get; set; } = string.Empty;

    public int AniosExperiencia { get; set; }

    public List<string> Especialidades { get; set; } = new();

    public string? TokenFCM { get; set; }

    public bool Disponible { get; set; } = true;

    public decimal RatingPromedio { get; set; }

    public Barberia Barberia { get; set; } = null!;

    public ICollection<HorarioSemana> HorariosSemana { get; set; } = new List<HorarioSemana>();

    public ICollection<BarberAvailability> Availabilities { get; set; } = new List<BarberAvailability>();

    public ICollection<BarberDayOff> DaysOff { get; set; } = new List<BarberDayOff>();

    public ICollection<BarberoServicio> BarberoServicios { get; set; } = new List<BarberoServicio>();

    public ICollection<Cita> Citas { get; set; } = new List<Cita>();

    public ICollection<BloqueoHorario> BloqueosHorario { get; set; } = new List<BloqueoHorario>();

    public ICollection<Review> Reviews { get; set; } = new List<Review>();
}
