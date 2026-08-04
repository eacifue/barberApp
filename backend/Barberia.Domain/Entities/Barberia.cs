using Barberia.Domain.Common;
using Barberia.Domain.Enums;

namespace Barberia.Domain.Entities;

public class Barberia : BaseEntity
{
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

    public TimeOnly HoraApertura { get; set; }

    public TimeOnly HoraCierre { get; set; }

    public List<DiaSemana> DiasDescanso { get; set; } = new();

    public bool Activa { get; set; } = true;
}
