using Barberia.Application.DTOs.Slots;

namespace Barberia.Application.Interfaces;

public interface ISlotBloqueoService
{
    Task<BloqueoResultDto> BloquearSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, Guid clienteId, CancellationToken cancellationToken);

    Task<bool> LiberarSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, string tokenBloqueo, CancellationToken cancellationToken);

    Task<BloqueoInfoDto?> ConsultarBloqueoAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, CancellationToken cancellationToken);

    Task<int> LiberarTodosDelClienteAsync(Guid clienteId, CancellationToken cancellationToken);
}
