namespace Barberia.Domain.Interfaces;

public interface IAuditableEntity
{
    DateTime CreatedAtUtc { get; set; }

    DateTime? UpdatedAtUtc { get; set; }
}
