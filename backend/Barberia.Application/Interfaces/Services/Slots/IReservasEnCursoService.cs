using Barberia.Application.DTOs.Slots;

namespace Barberia.Application.Interfaces.Services.Slots;

/// <summary>Reservas en curso del panel: horarios apartados por clientes que aún no confirman.</summary>
public interface IReservasEnCursoService
{
    Task<IReadOnlyList<ReservaEnCursoDto>> ListarAsync(CancellationToken cancellationToken);

    Task LiberarAsync(LiberarReservaRequest request, CancellationToken cancellationToken);
}
