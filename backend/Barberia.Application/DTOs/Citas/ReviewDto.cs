namespace Barberia.Application.DTOs.Citas;

public class ReviewDto
{
    public Guid Id { get; set; }

    public Guid CitaId { get; set; }

    public Guid BarberoId { get; set; }

    public int Calificacion { get; set; }

    public string? Comentario { get; set; }

    public DateTime CreatedAt { get; set; }
}
