namespace Barberia.Application.DTOs.Barberias;

public sealed class BarberiaDto
{
    public Guid Id { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Descripcion { get; set; } = string.Empty;

    public string Slogan { get; set; } = string.Empty;

    public string Telefono { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    public string SitioWeb { get; set; } = string.Empty;

    public string Direccion { get; set; } = string.Empty;

    public string Ciudad { get; set; } = string.Empty;

    public string Departamento { get; set; } = string.Empty;

    public string Pais { get; set; } = string.Empty;

    public decimal Latitud { get; set; }

    public decimal Longitud { get; set; }

    public string FotoPortada { get; set; } = string.Empty;

    public string HoraApertura { get; set; } = string.Empty;

    public string HoraCierre { get; set; } = string.Empty;

    public List<string> DiasDescanso { get; set; } = new();

    public bool Activa { get; set; }

    public bool Activo { get; set; }
}
