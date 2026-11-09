using Barberia.Application.DTOs.Slots;
using Barberia.Application.Exceptions;
using Barberia.Application.Services;
using Barberia.Domain.Entities;
using Barberia.Tests.Citas;
using Barberia.Tests.Gestion;

namespace Barberia.Tests.Reservas;

// Reservas en curso del panel: horarios que un cliente apartó en la app y aún
// no confirma. El bloqueo real vive en Redis; aquí se sustituye por un fake.
public sealed class ReservasEnCursoServiceTests : GestionTestBase
{
    private readonly FakeSlotBloqueoService slots = new();
    private readonly FakeNotificationService notificaciones = new();
    private readonly Guid barberoId = Guid.NewGuid();
    private readonly Guid clienteId = Guid.NewGuid();
    private static readonly DateOnly Sabado = new(2026, 11, 7);

    private ReservasEnCursoService NewService() => new(NewContext(), slots, notificaciones, Clock);

    private async Task SembrarAsync()
    {
        await using var seed = NewContext();
        seed.Barberos.Add(new Barbero { Id = barberoId, Nombre = "Julián", Apellido = "Restrepo" });
        seed.Clientes.Add(new Cliente { Id = clienteId, Nombre = "Kevin", Apellido = "Restrepo", Correo = "kevin@correo.co" });
        await seed.SaveChangesAsync();
    }

    private BloqueoActivoDto Bloqueo(TimeOnly hora, int segundosRestantes, Guid? barbero = null) =>
        new(barbero ?? barberoId, Sabado, hora, clienteId, Clock.GetUtcNow().UtcDateTime.AddSeconds(segundosRestantes - 300), Clock.GetUtcNow().UtcDateTime.AddSeconds(segundosRestantes));

    [Fact]
    public async Task Listar_devuelve_cada_reserva_con_nombres_de_cliente_y_barbero()
    {
        await SembrarAsync();
        slots.Bloqueos.Add(Bloqueo(new TimeOnly(14, 30), 192));

        var reservas = await NewService().ListarAsync(CancellationToken.None);

        var r = Assert.Single(reservas);
        Assert.Equal("Kevin Restrepo", r.ClienteNombre);
        Assert.Equal("Julián Restrepo", r.BarberoNombre);
        Assert.Equal(Sabado, r.FechaCita);
        Assert.Equal(new TimeOnly(14, 30), r.HoraInicio);
        Assert.Equal(192, r.SegundosRestantes);
    }

    [Fact]
    public async Task Listar_ordena_por_la_que_se_libera_primero_y_omite_las_vencidas()
    {
        await SembrarAsync();
        slots.Bloqueos.Add(Bloqueo(new TimeOnly(16, 0), 240));
        slots.Bloqueos.Add(Bloqueo(new TimeOnly(10, 0), 30));
        slots.Bloqueos.Add(Bloqueo(new TimeOnly(11, 0), 0));

        var reservas = await NewService().ListarAsync(CancellationToken.None);

        Assert.Equal([new TimeOnly(10, 0), new TimeOnly(16, 0)], reservas.Select(r => r.HoraInicio));
    }

    [Fact]
    public async Task Listar_omite_horarios_de_barberos_que_no_son_de_esta_barberia()
    {
        await SembrarAsync();
        slots.Bloqueos.Add(Bloqueo(new TimeOnly(14, 30), 120, barbero: Guid.NewGuid()));

        Assert.Empty(await NewService().ListarAsync(CancellationToken.None));
    }

    [Fact]
    public async Task Liberar_quita_el_bloqueo_y_avisa_al_cliente()
    {
        await SembrarAsync();
        slots.Bloqueos.Add(Bloqueo(new TimeOnly(14, 30), 120));

        await NewService().LiberarAsync(new LiberarReservaRequest { BarberoId = barberoId, FechaCita = Sabado, HoraInicio = new TimeOnly(14, 30) }, CancellationToken.None);

        Assert.Empty(slots.Bloqueos);
        var aviso = Assert.Single(notificaciones.Enviadas);
        Assert.Equal(("HorarioLiberadoCliente", clienteId), (aviso.Tipo, aviso.Destinatario));
        Assert.Contains("2:30 p. m.", aviso.Mensaje);
    }

    [Fact]
    public async Task Liberar_un_horario_que_ya_no_esta_apartado_responde_no_encontrado()
    {
        await SembrarAsync();

        var ex = await Assert.ThrowsAsync<NotFoundException>(() =>
            NewService().LiberarAsync(new LiberarReservaRequest { BarberoId = barberoId, FechaCita = Sabado, HoraInicio = new TimeOnly(14, 30) }, CancellationToken.None));

        Assert.Equal("Ese horario ya no está apartado.", ex.Message);
        Assert.Empty(notificaciones.Enviadas);
    }

    [Fact]
    public async Task Liberar_con_un_barbero_de_otra_barberia_responde_no_encontrado_sin_tocar_redis()
    {
        await SembrarAsync();
        var ajeno = Guid.NewGuid();
        slots.Bloqueos.Add(Bloqueo(new TimeOnly(14, 30), 120, barbero: ajeno));

        await Assert.ThrowsAsync<NotFoundException>(() =>
            NewService().LiberarAsync(new LiberarReservaRequest { BarberoId = ajeno, FechaCita = Sabado, HoraInicio = new TimeOnly(14, 30) }, CancellationToken.None));

        Assert.Single(slots.Bloqueos);
    }
}
