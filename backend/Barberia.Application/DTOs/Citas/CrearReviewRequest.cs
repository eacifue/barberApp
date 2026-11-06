namespace Barberia.Application.DTOs.Citas;

public class CrearReviewRequest
{
    /// <summary>Estrellas de 1 a 5.</summary>
    public int Calificacion { get; set; }

    /// <summary>Opcional, máximo 500 caracteres.</summary>
    public string? Comentario { get; set; }
}
