using Barberia.Application.DTOs.Servicios;

namespace Barberia.Application.Interfaces.Services.Servicios;

public interface IServicioService
{
    Task<List<ServicioDto>> GetAllByBarberiaAsync(Guid barberiaId, CancellationToken cancellationToken);

    Task<ServicioDto> GetByIdAsync(Guid id, CancellationToken cancellationToken);

    Task<ServicioDto> CreateAsync(CreateServicioRequest request, CancellationToken cancellationToken);

    Task<ServicioDto> UpdateAsync(Guid id, CreateServicioRequest request, CancellationToken cancellationToken);

    Task DeleteAsync(Guid id, CancellationToken cancellationToken);

    Task<List<ServicioDto>> GetByBarberoAsync(Guid barberoId, CancellationToken cancellationToken);
}
