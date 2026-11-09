using Barberia.Application.DTOs.Slots;

namespace Barberia.Application.Interfaces;

public interface ISlotBloqueoService
{
    Task<BloqueoResultDto> BloquearSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, Guid clienteId, CancellationToken cancellationToken);

    Task<bool> LiberarSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, string tokenBloqueo, CancellationToken cancellationToken);

    Task<BloqueoInfoDto?> ConsultarBloqueoAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, CancellationToken cancellationToken);

    Task<int> LiberarTodosDelClienteAsync(Guid clienteId, CancellationToken cancellationToken);

    /// <summary>Todos los horarios apartados que siguen vigentes.</summary>
    Task<IReadOnlyList<BloqueoActivoDto>> ListarActivosAsync(CancellationToken cancellationToken);

    /// <summary>Libera un horario apartado sin el token del cliente (uso de recepción). Devuelve el bloqueo liberado, o null si ya no existía.</summary>
    Task<BloqueoActivoDto?> LiberarSinTokenAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, CancellationToken cancellationToken);
}
