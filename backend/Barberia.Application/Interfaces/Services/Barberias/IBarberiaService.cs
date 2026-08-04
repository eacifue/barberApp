using Barberia.Application.DTOs.Barberias;

namespace Barberia.Application.Interfaces.Services.Barberias;

public interface IBarberiaService
{
    Task<List<BarberiaDto>> GetAllAsync(CancellationToken cancellationToken);

    Task<BarberiaDto> GetByIdAsync(Guid id, CancellationToken cancellationToken);

    Task<BarberiaDto> UpdateAsync(Guid id, UpsertBarberiaRequest request, CancellationToken cancellationToken);

    Task<Guid> GetCurrentBarberiaIdAsync(CancellationToken cancellationToken);
}
