namespace Barberia.Application.DTOs.Barberias;

/// <summary>Una fila del resumen del SuperAdmin: cómo va cada barbería este mes.</summary>
public sealed class ResumenBarberiaDto
{
    public Guid BarberiaId { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public bool Activa { get; set; }

    /// <summary>Citas del mes, sin canceladas ni «no asistió».</summary>
    public int CitasMes { get; set; }

    /// <summary>Cobrado en el mes: citas completadas.</summary>
    public decimal IngresosMes { get; set; }

    public int Clientes { get; set; }

    public int BarberosActivos { get; set; }
}
