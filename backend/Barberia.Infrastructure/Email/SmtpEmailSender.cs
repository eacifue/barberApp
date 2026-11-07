using System.Net;
using System.Net.Mail;
using Barberia.Application.Interfaces.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Barberia.Infrastructure.Email;

/// <summary>
/// Correo por SMTP. Configuración: `Smtp:Host`, `Smtp:Port` (587), `Smtp:User`,
/// `Smtp:Password`, `Smtp:From`, `Smtp:EnableSsl` (true).
/// </summary>
public sealed class SmtpEmailSender(IConfiguration configuration, ILogger<SmtpEmailSender> logger) : IEmailSender
{
    public async Task EnviarAsync(string destinatario, string asunto, string cuerpo, CancellationToken cancellationToken)
    {
        var host = configuration["Smtp:Host"]!;
        var port = int.TryParse(configuration["Smtp:Port"], out var p) ? p : 587;
        var from = configuration["Smtp:From"] ?? configuration["Smtp:User"] ?? "no-responder@barberia.local";
        using var client = new SmtpClient(host, port)
        {
            EnableSsl = !bool.TryParse(configuration["Smtp:EnableSsl"], out var ssl) || ssl,
        };
        if (!string.IsNullOrWhiteSpace(configuration["Smtp:User"]))
        {
            client.Credentials = new NetworkCredential(configuration["Smtp:User"], configuration["Smtp:Password"]);
        }

        using var message = new MailMessage(new MailAddress(from, "BarberShop Medellín"), new MailAddress(destinatario))
        {
            Subject = asunto,
            Body = cuerpo,
            IsBodyHtml = false,
        };

        try
        {
            await client.SendMailAsync(message, cancellationToken);
        }
        catch (SmtpException ex)
        {
            // No se propaga: la respuesta al usuario no debe revelar si el envío falló para una cuenta concreta.
            logger.LogError(ex, "No se pudo enviar el correo «{Asunto}».", asunto);
        }
    }
}
