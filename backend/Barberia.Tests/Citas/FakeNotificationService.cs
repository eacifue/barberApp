using Barberia.Application.Interfaces.Services;

namespace Barberia.Tests.Citas;

/// <summary>Registra las notificaciones enviadas para verificarlas como efecto observable.</summary>
public sealed class FakeNotificationService : INotificationService
{
    public List<(string Tipo, Guid Destinatario, string Mensaje)> Enviadas { get; } = [];

    public Task SendAppointmentCreatedAsync(Guid clienteId, string message, CancellationToken cancellationToken) => Registrar("SendAppointmentCreated", clienteId, message);

    public Task NotificarNuevaCitaAsync(Guid barberoId, string mensaje, CancellationToken cancellationToken) => Registrar("NuevaCita", barberoId, mensaje);

    public Task NotificarCitaCreadaClienteAsync(Guid clienteId, string mensaje, CancellationToken cancellationToken) => Registrar("CitaCreadaCliente", clienteId, mensaje);

    public Task NotificarCitaCanceladaBarberoAsync(Guid barberoId, string mensaje, CancellationToken cancellationToken) => Registrar("CitaCanceladaBarbero", barberoId, mensaje);

    public Task NotificarCitaCanceladaClienteAsync(Guid clienteId, string mensaje, CancellationToken cancellationToken) => Registrar("CitaCanceladaCliente", clienteId, mensaje);

    public Task NotificarCitaNoAsistidaClienteAsync(Guid clienteId, string mensaje, CancellationToken cancellationToken) => Registrar("CitaNoAsistidaCliente", clienteId, mensaje);

    private Task Registrar(string tipo, Guid destinatario, string mensaje)
    {
        Enviadas.Add((tipo, destinatario, mensaje));
        return Task.CompletedTask;
    }
}
