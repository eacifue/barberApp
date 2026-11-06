namespace Barberia.Application.DTOs.Citas;

public class CitaDto
{
    public Guid Id { get; set; }

    public string Estado { get; set; } = string.Empty;

    public DateOnly FechaCita { get; set; }

    public TimeOnly HoraInicio { get; set; }

    public TimeOnly HoraFin { get; set; }

    public decimal PrecioFinal { get; set; }

    public string? Notas { get; set; }

    public ClienteCitaDto Cliente { get; set; } = new();

    public BarberoCitaDto Barbero { get; set; } = new();

    public ServicioCitaDto Servicio { get; set; } = new();

    public DateTime CreatedAt { get; set; }

    /// <summary>El cliente ya calificó esta cita (oculta «Calificar servicio» en la app).</summary>
    public bool TieneReview { get; set; }
}

public class ClienteCitaDto
{
    public Guid Id { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Apellido { get; set; } = string.Empty;

    public string Telefono { get; set; } = string.Empty;
}

public class BarberoCitaDto
{
    public Guid Id { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Apellido { get; set; } = string.Empty;

    public string? FotoUrl { get; set; }
}

public class ServicioCitaDto
{
    public Guid Id { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public int DuracionMinutos { get; set; }

    public decimal Precio { get; set; }
}
