using Barberia.Application.DTOs.Auth;

namespace Barberia.Application.Interfaces.Services.Auth;

/// <summary>Recuperar contraseña con un código de 6 dígitos enviado por correo.</summary>
public interface IRecuperacionPasswordService
{
    /// <summary>Envía un código si el correo pertenece a una cuenta activa. No revela si existe.</summary>
    Task SolicitarCodigoAsync(SolicitarCodigoRequest request, CancellationToken cancellationToken);

    /// <summary>Cambia la contraseña si el código es válido, no venció y no superó los intentos.</summary>
    Task RestablecerAsync(RestablecerPasswordRequest request, CancellationToken cancellationToken);
}
