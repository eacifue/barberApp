using Barberia.Domain.Common;

namespace Barberia.Domain.Entities;

/// <summary>
/// Código de un solo uso para restablecer la contraseña. Se guarda solo su hash;
/// `Activo = false` cuando se usa, vence o lo reemplaza uno nuevo.
/// </summary>
public class CodigoRecuperacion : BaseEntity
{
    public Guid ClienteId { get; set; }

    public string CodigoHash { get; set; } = string.Empty;

    /// <summary>Hora de negocio en que se emitió (CreatedAt lo pisa SaveChanges con el reloj del sistema).</summary>
    public DateTime EmitidoEn { get; set; }

    public DateTime ExpiraEn { get; set; }

    public int Intentos { get; set; }

    public DateTime? UsadoEn { get; set; }

    public Cliente? Cliente { get; set; }
}
