using Barberia.Application.DTOs.Barberias;

namespace Barberia.Application.Interfaces.Services.Barberias;

public interface IBarberiaService
{
    Task<List<BarberiaDto>> GetAllAsync(CancellationToken cancellationToken);

    Task<BarberiaDto> GetByIdAsync(Guid id, CancellationToken cancellationToken);

    Task<BarberiaDto> UpdateAsync(Guid id, UpsertBarberiaRequest request, CancellationToken cancellationToken);

    Task<BarberiaDto> CrearAsync(CrearBarberiaRequest request, CancellationToken cancellationToken);

    /// <summary>Desactivar deja fuera a su personal y clientes; nada se borra.</summary>
    /// <summary>Para el SuperAdmin: una fila por barbería con el mes en curso (hora de Colombia).</summary>
    Task<List<ResumenBarberiaDto>> ResumenAsync(CancellationToken cancellationToken);

    Task<BarberiaDto> CambiarEstadoAsync(Guid id, bool activa, CancellationToken cancellationToken);
}
