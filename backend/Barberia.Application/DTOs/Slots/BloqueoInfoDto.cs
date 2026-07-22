namespace Barberia.Application.DTOs.Slots;

public class BloqueoInfoDto
{
    public Guid ClienteId { get; set; }

    public string TokenBloqueo { get; set; } = string.Empty;

    public DateTime BloqueadoEn { get; set; }

    public DateTime ExpiraEn { get; set; }

    public int MinutosRestantes { get; set; }
}
