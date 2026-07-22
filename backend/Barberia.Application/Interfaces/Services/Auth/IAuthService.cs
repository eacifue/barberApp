using Barberia.Application.DTOs.Auth;

namespace Barberia.Application.Interfaces.Services.Auth;

public interface IAuthService
{
    Task<AuthResponseDto> RegistroAsync(RegistroClienteRequest request, CancellationToken cancellationToken);

    Task<AuthResponseDto> LoginAsync(LoginRequest request, CancellationToken cancellationToken);

    Task UpdateClienteFcmTokenAsync(string token, CancellationToken cancellationToken);

    /// <summary>Invalida la sesión del cliente y limpia sus bloqueos pendientes en Redis.</summary>
    Task LogoutAsync(CancellationToken cancellationToken);
}
