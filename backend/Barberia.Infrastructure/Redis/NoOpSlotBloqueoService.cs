using Barberia.Application.DTOs.Slots;
using Barberia.Application.Interfaces;

namespace Barberia.Infrastructure.Redis;

public class NoOpSlotBloqueoService : ISlotBloqueoService
{
    public Task<BloqueoResultDto> BloquearSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, Guid clienteId, CancellationToken cancellationToken)
    {
        return Task.FromResult(new BloqueoResultDto
        {
            Exitoso = false,
            MensajeError = "Redis no está disponible.",
            Mensaje = "No se pudo reservar temporalmente el horario.",
            ExpiresInSeconds = 0
        });
    }

    public Task<bool> LiberarSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, string tokenBloqueo, CancellationToken cancellationToken)
    {
        return Task.FromResult(false);
    }

    public Task<BloqueoInfoDto?> ConsultarBloqueoAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, CancellationToken cancellationToken)
    {
        return Task.FromResult<BloqueoInfoDto?>(null);
    }

    public Task<int> LiberarTodosDelClienteAsync(Guid clienteId, CancellationToken cancellationToken)
    {
        return Task.FromResult(0);
    }
}
