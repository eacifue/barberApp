using Barberia.Application.DTOs.Auth;
using Barberia.Application.Interfaces.Services.Auth;
using Barberia.Shared;
using Barberia.Shared.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Barberia.API.Controllers;

[ApiController]
public class AuthController : ControllerBase
{
    private readonly IAuthService authService;
    private readonly IRecuperacionPasswordService recuperacionPasswordService;

    public AuthController(IAuthService authService, IRecuperacionPasswordService recuperacionPasswordService)
    {
        this.authService = authService;
        this.recuperacionPasswordService = recuperacionPasswordService;
    }

    /// <summary>Envía un código de 6 dígitos al correo. Responde igual exista o no la cuenta.</summary>
    [HttpPost("api/v1/auth/recuperar")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<object?>>> SolicitarCodigoAsync(
        [FromBody] SolicitarCodigoRequest request,
        CancellationToken cancellationToken)
    {
        await recuperacionPasswordService.SolicitarCodigoAsync(request, cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, "Si el correo está registrado, te enviamos un código. Revisa también la carpeta de spam."));
    }

    /// <summary>Cambia la contraseña con el código recibido por correo.</summary>
    [HttpPost("api/v1/auth/restablecer")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<object?>>> RestablecerAsync(
        [FromBody] RestablecerPasswordRequest request,
        CancellationToken cancellationToken)
    {
        await recuperacionPasswordService.RestablecerAsync(request, cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, "Listo, tu contraseña cambió. Ya puedes entrar."));
    }

    [HttpPost("api/v1/auth/registro")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<AuthResponseDto>>> RegistroAsync(
        [FromBody] RegistroClienteRequest request,
        CancellationToken cancellationToken)
    {
        var result = await authService.RegistroAsync(request, cancellationToken);
        return Ok(ApiResponse<AuthResponseDto>.Ok(result, "Registro completado correctamente."));
    }

    [HttpPost("api/v1/auth/login")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<AuthResponseDto>>> LoginAsync(
        [FromBody] LoginRequest request,
        CancellationToken cancellationToken)
    {
        var result = await authService.LoginAsync(request, cancellationToken);
        return Ok(ApiResponse<AuthResponseDto>.Ok(result, "Inicio de sesión exitoso."));
    }

    [HttpPut("api/v1/auth/fcm-token")]
    [Authorize(Policy = Roles.Cliente)]
    public async Task<ActionResult<ApiResponse<object?>>> UpdateFcmTokenAsync(
        [FromBody] UpdateClienteFcmTokenRequest request,
        CancellationToken cancellationToken)
    {
        await authService.UpdateClienteFcmTokenAsync(request.Token, cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, "Token FCM actualizado correctamente."));
    }

    [HttpPost("api/v1/auth/logout")]
    [Authorize(Policy = Roles.Cliente)]
    public async Task<ActionResult<ApiResponse<object?>>> LogoutAsync(CancellationToken cancellationToken)
    {
        await authService.LogoutAsync(cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, "Sesión cerrada correctamente."));
    }
}
