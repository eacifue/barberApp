using Barberia.Application.DTOs.Clientes;

namespace Barberia.Application.Interfaces.Services.Clientes;

public interface IClienteAdminService
{
    Task<List<ClienteDto>> GetAllAsync(CancellationToken cancellationToken);

    Task<ClienteDto> GetByIdAsync(Guid id, CancellationToken cancellationToken);

    Task<ClienteDto> CreateAsync(CreateClienteAdminRequest request, CancellationToken cancellationToken);

    Task<ClienteDto> UpdateAsync(Guid id, UpdateClienteAdminRequest request, CancellationToken cancellationToken);

    Task DeleteAsync(Guid id, CancellationToken cancellationToken);
}
