using Barberia.Application.Interfaces.Services;
using Microsoft.Extensions.Logging;

namespace Barberia.Infrastructure.Email;

/// <summary>
/// Sin SMTP configurado. En Development escribe el correo completo en el log
/// (para ver el código de recuperación); en otros entornos solo advierte.
/// </summary>
public sealed class LogEmailSender(ILogger<LogEmailSender> logger, bool incluirCuerpo) : IEmailSender
{
    public Task EnviarAsync(string destinatario, string asunto, string cuerpo, CancellationToken cancellationToken)
    {
        if (incluirCuerpo)
        {
            logger.LogInformation("Correo (sin SMTP) para {Destinatario} · {Asunto}\n{Cuerpo}", destinatario, asunto, cuerpo);
        }
        else
        {
            logger.LogWarning("SMTP no configurado: no se envió «{Asunto}». Configura Smtp:Host.", asunto);
        }

        return Task.CompletedTask;
    }
}
