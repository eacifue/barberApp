namespace Barberia.Application.DTOs.Citas;

public class CancelarCitaRequest
{
    public Guid CitaId { get; set; }

    public string? Motivo { get; set; }
}
