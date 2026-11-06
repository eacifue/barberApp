namespace Barberia.Application.Interfaces.Services;

public interface INotificationService
{
    Task SendAppointmentCreatedAsync(Guid clienteId, string message, CancellationToken cancellationToken);

    Task NotificarNuevaCitaAsync(Guid barberoId, string mensaje, CancellationToken cancellationToken);

    Task NotificarCitaCreadaClienteAsync(Guid clienteId, string mensaje, CancellationToken cancellationToken);

    Task NotificarCitaCanceladaBarberoAsync(Guid barberoId, string mensaje, CancellationToken cancellationToken);

    Task NotificarCitaCanceladaClienteAsync(Guid clienteId, string mensaje, CancellationToken cancellationToken);

    Task NotificarCitaNoAsistidaClienteAsync(Guid clienteId, string mensaje, CancellationToken cancellationToken);
}
