using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Interfaces.Services.Barberias;

namespace Barberia.Infrastructure.Services;

/// <summary>La barbería de la petición: la del token, o la que eligió el SuperAdmin.</summary>
public sealed class BarberiaDeLaPeticion(ICurrentUserService currentUser) : IBarberiaContexto
{
    public Task<Guid> ObtenerIdAsync(CancellationToken cancellationToken) =>
        currentUser.BarberiaId is { } id
            ? Task.FromResult(id)
            : throw new ValidationException("Elige la barbería.");

    public Task<Guid?> ObtenerIdSiHayAsync(CancellationToken cancellationToken) => Task.FromResult(currentUser.BarberiaId);
}
