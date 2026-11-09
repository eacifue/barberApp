using Barberia.Application.DTOs.Slots;
using Barberia.Application.Interfaces;

namespace Barberia.Tests.Reservas;

/// <summary>Bloqueos en memoria en lugar de Redis. Lo que se libere desaparece de la lista.</summary>
public sealed class FakeSlotBloqueoService : ISlotBloqueoService
{
    public List<BloqueoActivoDto> Bloqueos { get; } = [];

    public Task<IReadOnlyList<BloqueoActivoDto>> ListarActivosAsync(CancellationToken cancellationToken) =>
        Task.FromResult<IReadOnlyList<BloqueoActivoDto>>(Bloqueos.ToList());

    public Task<BloqueoActivoDto?> LiberarSinTokenAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, CancellationToken cancellationToken)
    {
        var b = Bloqueos.FirstOrDefault(x => x.BarberoId == barberoId && x.Fecha == fecha && x.HoraInicio == horaInicio);
        if (b is not null) Bloqueos.Remove(b);
        return Task.FromResult(b);
    }

    public Task<BloqueoResultDto> BloquearSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, Guid clienteId, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<bool> LiberarSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, string tokenBloqueo, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<BloqueoInfoDto?> ConsultarBloqueoAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<int> LiberarTodosDelClienteAsync(Guid clienteId, CancellationToken cancellationToken) => throw new NotSupportedException();
}
