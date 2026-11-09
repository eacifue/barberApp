using Barberia.Application.DTOs.Citas;

namespace Barberia.Application.Interfaces.Services.Citas;

public interface ICitaService
{
    Task<CitaDto> CrearCitaAsync(CreateCitaRequest request, CancellationToken cancellationToken);

    Task<CitaDto> CancelarCitaAsync(CancelarCitaRequest request, CancellationToken cancellationToken);

    Task<CitaDto> ConfirmarCitaAsync(Guid citaId, CancellationToken cancellationToken);

    Task<CitaDto> CompletarCitaAsync(Guid citaId, CancellationToken cancellationToken);

    /// <summary>El barbero empieza el servicio: Confirmada → En progreso.</summary>
    Task<CitaDto> IniciarCitaAsync(Guid citaId, CancellationToken cancellationToken);

    /// <summary>El cliente no llegó: Pendiente o Confirmada → No asistió, solo desde la hora de inicio.</summary>
    Task<CitaDto> MarcarNoAsistioAsync(Guid citaId, CancellationToken cancellationToken);

    Task<List<CitaDto>> GetByClienteAsync(Guid clienteId, CancellationToken cancellationToken);

    Task<List<CitaDto>> GetByBarberoAsync(Guid barberoId, DateOnly fecha, CancellationToken cancellationToken);

    Task<CitaDto> GetByIdAsync(Guid citaId, CancellationToken cancellationToken);

    /// <summary>El cliente autenticado califica su propia cita completada (una reseña por cita).</summary>
    Task<ReviewDto> CrearReviewAsync(Guid citaId, CrearReviewRequest request, CancellationToken cancellationToken);

    Task<List<CitaDto>> GetAdminListAsync(
        Guid? barberoId,
        DateOnly? fechaInicio,
        DateOnly? fechaFin,
        string? estado,
        int page,
        int pageSize,
        CancellationToken cancellationToken);
}
