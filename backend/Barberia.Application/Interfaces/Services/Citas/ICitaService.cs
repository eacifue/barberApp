using Barberia.Application.DTOs.Citas;

namespace Barberia.Application.Interfaces.Services.Citas;

public interface ICitaService
{
    Task<CitaDto> CrearCitaAsync(CreateCitaRequest request, CancellationToken cancellationToken);

    Task<CitaDto> CancelarCitaAsync(CancelarCitaRequest request, CancellationToken cancellationToken);

    Task<CitaDto> ConfirmarCitaAsync(Guid citaId, CancellationToken cancellationToken);

    Task<CitaDto> CompletarCitaAsync(Guid citaId, CancellationToken cancellationToken);

    Task<List<CitaDto>> GetByClienteAsync(Guid clienteId, CancellationToken cancellationToken);

    Task<List<CitaDto>> GetByBarberoAsync(Guid barberoId, DateOnly fecha, CancellationToken cancellationToken);

    Task<CitaDto> GetByIdAsync(Guid citaId, CancellationToken cancellationToken);

    Task<List<CitaDto>> GetAdminListAsync(
        Guid? barberoId,
        Guid? barberiaId,
        DateOnly? fechaInicio,
        DateOnly? fechaFin,
        string? estado,
        int page,
        int pageSize,
        CancellationToken cancellationToken);
}
