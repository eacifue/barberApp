using Barberia.Application.DTOs.Barberos;

namespace Barberia.Application.Interfaces.Services.Barberos;

public interface IBarberoService
{
    Task<List<BarberoDto>> GetAllByBarberiaAsync(Guid barberiaId, CancellationToken cancellationToken);

    Task<BarberoDto> GetByIdAsync(Guid id, CancellationToken cancellationToken);

    Task<List<BarberoDto>> GetByServicioAsync(Guid servicioId, CancellationToken cancellationToken);

    Task<BarberoDto> CreateAsync(CreateBarberoRequest request, CancellationToken cancellationToken);

    Task<BarberoDto> UpdateAsync(Guid id, CreateBarberoRequest request, CancellationToken cancellationToken);

    Task DeleteAsync(Guid id, CancellationToken cancellationToken);

    Task AsignarServicioAsync(Guid barberoId, Guid servicioId, CancellationToken cancellationToken);

    Task<List<HorarioSemanaDto>> SetHorariosAsync(SetHorarioRequest request, CancellationToken cancellationToken);

    Task<List<HorarioSemanaDto>> GetHorariosAsync(Guid barberoId, CancellationToken cancellationToken);

    Task UpdateTokenFCMAsync(Guid barberoId, string token, CancellationToken cancellationToken);
}
