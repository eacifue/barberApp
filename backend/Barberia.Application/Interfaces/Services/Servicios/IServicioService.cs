using Barberia.Application.DTOs.Servicios;

namespace Barberia.Application.Interfaces.Services.Servicios;

public interface IServicioService
{
    /// <summary>Catálogo; con <paramref name="incluirInactivos"/> también los desactivados (panel).</summary>
    Task<List<ServicioDto>> GetAllByBarberiaAsync(Guid barberiaId, CancellationToken cancellationToken, bool incluirInactivos = false);

    Task<ServicioDto> GetByIdAsync(Guid id, CancellationToken cancellationToken);

    Task<ServicioDto> CreateAsync(CreateServicioRequest request, CancellationToken cancellationToken);

    Task<ServicioDto> UpdateAsync(Guid id, CreateServicioRequest request, CancellationToken cancellationToken);

    /// <summary>Vuelve a ofrecer un servicio desactivado.</summary>
    Task<ServicioDto> ActivarAsync(Guid id, CancellationToken cancellationToken);

    Task DeleteAsync(Guid id, CancellationToken cancellationToken);

    Task<List<ServicioDto>> GetByBarberoAsync(Guid barberoId, CancellationToken cancellationToken);
}
