namespace Barberia.Application.Interfaces.Services;

/// <summary>Envío de correos transaccionales (texto plano).</summary>
public interface IEmailSender
{
    Task EnviarAsync(string destinatario, string asunto, string cuerpo, CancellationToken cancellationToken);
}
