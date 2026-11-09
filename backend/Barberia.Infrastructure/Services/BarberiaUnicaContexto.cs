using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services.Barberias;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Infrastructure.Services;

/// <summary>
/// Temporal (fase A del paso a varias barberías): mientras el token no trae la
/// barbería, todo se crea en la barbería original del sistema, la más antigua.
/// </summary>
public sealed class BarberiaUnicaContexto(IBarberiaDbContext dbContext) : IBarberiaContexto
{
    private Guid? barberiaId;

    public async Task<Guid> ObtenerIdAsync(CancellationToken cancellationToken)
    {
        barberiaId ??= await dbContext.Barberias
            .AsNoTracking()
            .IgnoreQueryFilters()
            .OrderBy(x => x.CreatedAt)
            .Select(x => (Guid?)x.Id)
            .FirstOrDefaultAsync(cancellationToken);

        return barberiaId ?? throw new ValidationException("Todavía no hay una barbería configurada.");
    }
}
