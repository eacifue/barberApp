using Barberia.Application.Exceptions;
using Barberia.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.Citas;

// Transiciones de estado que usa la agenda del panel: Iniciar y No asistió.
// La cita sembrada es el 28 oct 2026 de 6:00 a 6:30 p. m. (hora de Medellín, UTC−5).
public class CitaServiceEstadoTests : CitaServiceTestBase
{
    private async Task<EstadoCita> EstadoGuardadoAsync(Guid citaId)
    {
        await using var verify = NewContext(clienteId);
        return (await verify.Citas.IgnoreQueryFilters().SingleAsync(x => x.Id == citaId)).Estado;
    }

    [Fact]
    public async Task Iniciar_CitaConfirmada_PasaAEnProgreso()
    {
        var citaId = await SeedCitaAsync(EstadoCita.Confirmada);
        await using var context = NewContext(clienteId);

        var dto = await NewService(context, clienteId).IniciarCitaAsync(citaId, CancellationToken.None);

        Assert.Equal("EnProgreso", dto.Estado);
        Assert.Equal(EstadoCita.EnProgreso, await EstadoGuardadoAsync(citaId));
    }

    [Theory]
    [InlineData(EstadoCita.Pendiente)]
    [InlineData(EstadoCita.EnProgreso)]
    [InlineData(EstadoCita.Completada)]
    [InlineData(EstadoCita.Cancelada)]
    [InlineData(EstadoCita.NoShow)]
    public async Task Iniciar_CitaNoConfirmada_RechazaYNoCambiaElEstado(EstadoCita estado)
    {
        var citaId = await SeedCitaAsync(estado);
        await using var context = NewContext(clienteId);

        var ex = await Assert.ThrowsAsync<ConflictException>(() => NewService(context, clienteId).IniciarCitaAsync(citaId, CancellationToken.None));

        Assert.Equal("Solo se pueden iniciar citas confirmadas.", ex.Message);
        Assert.Equal(estado, await EstadoGuardadoAsync(citaId));
    }

    [Theory]
    [InlineData(EstadoCita.Confirmada)]
    [InlineData(EstadoCita.Pendiente)]
    public async Task NoAsistio_DespuesDeLaHoraDeInicio_MarcaNoShowYAvisaAlCliente(EstadoCita estado)
    {
        var citaId = await SeedCitaAsync(estado);
        // 6:20 p. m. en Medellín: ya pasó la hora de inicio.
        Clock.SetUtcNow(new DateTimeOffset(2026, 10, 28, 23, 20, 0, TimeSpan.Zero));
        await using var context = NewContext(clienteId);

        var dto = await NewService(context, clienteId).MarcarNoAsistioAsync(citaId, CancellationToken.None);

        Assert.Equal("NoShow", dto.Estado);
        Assert.Equal(EstadoCita.NoShow, await EstadoGuardadoAsync(citaId));
        var aviso = Assert.Single(Notifications.Enviadas);
        Assert.Equal(("CitaNoAsistidaCliente", clienteId), (aviso.Tipo, aviso.Destinatario));
    }

    [Fact]
    public async Task NoAsistio_AntesDeLaHoraDeInicio_RechazaSinAvisar()
    {
        var citaId = await SeedCitaAsync(EstadoCita.Confirmada);
        // 5:59 p. m. en Medellín = 22:59 UTC, un minuto antes de la cita.
        Clock.SetUtcNow(new DateTimeOffset(2026, 10, 28, 22, 59, 0, TimeSpan.Zero));
        await using var context = NewContext(clienteId);

        var ex = await Assert.ThrowsAsync<ConflictException>(() => NewService(context, clienteId).MarcarNoAsistioAsync(citaId, CancellationToken.None));

        Assert.Equal("Podrás marcar «No asistió» desde la hora de inicio de la cita.", ex.Message);
        Assert.Equal(EstadoCita.Confirmada, await EstadoGuardadoAsync(citaId));
        Assert.Empty(Notifications.Enviadas);
    }

    [Fact]
    public async Task NoAsistio_JustoALaHoraDeInicio_SePermite()
    {
        var citaId = await SeedCitaAsync(EstadoCita.Confirmada);
        // 6:00 p. m. en Medellín = 23:00 UTC.
        Clock.SetUtcNow(new DateTimeOffset(2026, 10, 28, 23, 0, 0, TimeSpan.Zero));
        await using var context = NewContext(clienteId);

        var dto = await NewService(context, clienteId).MarcarNoAsistioAsync(citaId, CancellationToken.None);

        Assert.Equal("NoShow", dto.Estado);
    }

    [Theory]
    [InlineData(EstadoCita.EnProgreso)]
    [InlineData(EstadoCita.Completada)]
    [InlineData(EstadoCita.Cancelada)]
    [InlineData(EstadoCita.NoShow)]
    public async Task NoAsistio_CitaNoPendienteNiConfirmada_RechazaSinAvisar(EstadoCita estado)
    {
        var citaId = await SeedCitaAsync(estado);
        Clock.SetUtcNow(new DateTimeOffset(2026, 10, 28, 23, 20, 0, TimeSpan.Zero));
        await using var context = NewContext(clienteId);

        var ex = await Assert.ThrowsAsync<ConflictException>(() => NewService(context, clienteId).MarcarNoAsistioAsync(citaId, CancellationToken.None));

        Assert.Equal("Solo puedes marcar «No asistió» en citas pendientes o confirmadas.", ex.Message);
        Assert.Equal(estado, await EstadoGuardadoAsync(citaId));
        Assert.Empty(Notifications.Enviadas);
    }
}
