using Barberia.Domain.Common;

namespace Barberia.Domain.Entities;

public class Cliente : BaseEntity
{
    /// <summary>
    /// Rol del usuario dentro del sistema. Valores: "Admin", "AdministradorBarberia", "Barbero", "Cliente".
    /// </summary>
    public string Rol { get; set; } = "Cliente";

    /// <summary>
    /// Perfil de barbero asociado (solo cuando Rol = "Barbero").
    /// </summary>
    public Guid? BarberoId { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Apellido { get; set; } = string.Empty;

    public string Telefono { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    public string PasswordHash { get; set; } = string.Empty;

    public string? FotoUrl { get; set; }

    public string? TokenFCM { get; set; }

    public DateTime? UltimaCita { get; set; }

    public int TotalCitas { get; set; }

    public ICollection<Cita> Citas { get; set; } = new List<Cita>();

    public ICollection<Review> Reviews { get; set; } = new List<Review>();
}
