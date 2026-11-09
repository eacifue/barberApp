namespace Barberia.Application.DTOs.Barberias;

public class UpsertBarberiaRequest
{
    public string Nombre { get; set; } = string.Empty;

    public string? Descripcion { get; set; }

    public string? Slogan { get; set; }

    public string Telefono { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    public string? SitioWeb { get; set; }

    public string Direccion { get; set; } = string.Empty;

    public string Ciudad { get; set; } = string.Empty;

    public string Departamento { get; set; } = string.Empty;

    public string Pais { get; set; } = string.Empty;

    public decimal Latitud { get; set; }

    public decimal Longitud { get; set; }

    public string? FotoPortada { get; set; }

    public TimeOnly HoraApertura { get; set; }

    public TimeOnly HoraCierre { get; set; }

    public List<string> DiasDescanso { get; set; } = new();

    public bool Activa { get; set; } = true;
}
