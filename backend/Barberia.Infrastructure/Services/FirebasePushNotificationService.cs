using Barberia.Application.Interfaces.Services;
using FirebaseAdmin.Messaging;
using Microsoft.Extensions.Logging;

namespace Barberia.Infrastructure.Services;

public class FirebasePushNotificationService : INotificationService
{
    private readonly ILogger<FirebasePushNotificationService> logger;

    public FirebasePushNotificationService(ILogger<FirebasePushNotificationService> logger)
    {
        this.logger = logger;
    }

    public async Task SendAppointmentCreatedAsync(Guid clienteId, string message, CancellationToken cancellationToken)
    {
        await SendToClienteAsync(clienteId, "Cita creada", message, cancellationToken);
    }

    public async Task NotificarNuevaCitaAsync(Guid barberoId, string mensaje, CancellationToken cancellationToken)
    {
        await SendToBarberoAsync(barberoId, "Nueva cita", mensaje, cancellationToken);
    }

    public async Task NotificarCitaCreadaClienteAsync(Guid clienteId, string mensaje, CancellationToken cancellationToken)
    {
        await SendToClienteAsync(clienteId, "Cita creada", mensaje, cancellationToken);
    }

    public async Task NotificarCitaCanceladaBarberoAsync(Guid barberoId, string mensaje, CancellationToken cancellationToken)
    {
        await SendToBarberoAsync(barberoId, "Cita cancelada", mensaje, cancellationToken);
    }

    public async Task NotificarCitaCanceladaClienteAsync(Guid clienteId, string mensaje, CancellationToken cancellationToken)
    {
        await SendToClienteAsync(clienteId, "Cita cancelada", mensaje, cancellationToken);
    }

    public async Task NotificarCitaNoAsistidaClienteAsync(Guid clienteId, string mensaje, CancellationToken cancellationToken)
    {
        await SendToClienteAsync(clienteId, "Te esperábamos", mensaje, cancellationToken);
    }

    public async Task NotificarHorarioLiberadoClienteAsync(Guid clienteId, string mensaje, CancellationToken cancellationToken)
    {
        await SendToClienteAsync(clienteId, "Tu horario se liberó", mensaje, cancellationToken);
    }

    private async Task SendToClienteAsync(Guid clienteId, string titulo, string mensaje, CancellationToken cancellationToken)
    {
        try
        {
            var firebaseMessage = new Message
            {
                Topic = $"cliente-{clienteId}",
                Notification = new Notification
                {
                    Title = titulo,
                    Body = mensaje
                }
            };

            _ = await FirebaseMessaging.DefaultInstance.SendAsync(firebaseMessage, cancellationToken);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "No se pudo enviar la notificación FCM para el cliente {ClienteId}", clienteId);
        }
    }

    private async Task SendToBarberoAsync(Guid barberoId, string titulo, string mensaje, CancellationToken cancellationToken)
    {
        try
        {
            var firebaseMessage = new Message
            {
                Topic = $"barbero-{barberoId}",
                Notification = new Notification
                {
                    Title = titulo,
                    Body = mensaje
                }
            };

            _ = await FirebaseMessaging.DefaultInstance.SendAsync(firebaseMessage, cancellationToken);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "No se pudo enviar la notificación FCM para el barbero {BarberoId}", barberoId);
        }
    }
}
