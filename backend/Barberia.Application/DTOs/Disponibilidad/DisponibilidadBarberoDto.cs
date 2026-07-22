namespace Barberia.Application.DTOs.Disponibilidad;

public class DisponibilidadBarberoDto
{
    public Guid BarberoId { get; set; }

    public string BarberoNombre { get; set; } = string.Empty;

    public Guid ServicioId { get; set; }

    public int DuracionServicioMin { get; set; }

    public DateOnly Fecha { get; set; }

    public List<SlotDisponibleDto> Slots { get; set; } = new();
}
