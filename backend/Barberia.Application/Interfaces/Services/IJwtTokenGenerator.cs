using Barberia.Domain.Entities;

namespace Barberia.Application.Interfaces.Services;

public interface IJwtTokenGenerator
{
    string GenerateClienteToken(Cliente cliente);
}
