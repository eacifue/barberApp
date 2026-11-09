using Barberia.Application.DTOs.Citas;
using Barberia.Application.DTOs.Slots;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces;
using Barberia.Application.Services;
using Barberia.Application.Validators.Citas;
using Barberia.Domain.Entities;
using Barberia.Tests.Citas;
using Barberia.Tests.Gestion;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.MultiBarberia;

// Una cita vive en la barbería de su barbero, y solo junta piezas de esa barbería.
public sealed class CitaBarberiaTests : GestionTestBase
{
    private const string Token = "token-de-bloqueo";

    /// <summary>Todos los horarios están apartados por quien reserva, con el token de la prueba.</summary>
    private sealed class SlotApartado : ISlotBloqueoService
    {
        public Task<BloqueoInfoDto?> ConsultarBloqueoAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, CancellationToken cancellationToken) =>
            Task.FromResult<BloqueoInfoDto?>(new BloqueoInfoDto { ClienteId = ClienteQueReserva, TokenBloqueo = Token });

        public Task<bool> LiberarSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, string tokenBloqueo, CancellationToken cancellationToken) => Task.FromResult(true);

        public Guid ClienteQueReserva { get; set; }

        public Task<BloqueoResultDto> BloquearSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, Guid clienteId, CancellationToken cancellationToken) => throw new NotSupportedException();

        public Task<int> LiberarTodosDelClienteAsync(Guid clienteId, CancellationToken cancellationToken) => throw new NotSupportedException();

        public Task<IReadOnlyList<BloqueoActivoDto>> ListarActivosAsync(CancellationToken cancellationToken) => throw new NotSupportedException();

        public Task<BloqueoActivoDto?> LiberarSinTokenAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, CancellationToken cancellationToken) => throw new NotSupportedException();
    }

    private readonly Guid barberiaA = Guid.NewGuid();
    private readonly Guid barberiaB = Guid.NewGuid();
    private readonly SlotApartado slots = new();

    // La regla de «no reservar en el pasado» usa el reloj real; una semana adelante siempre es futuro.
    private static readonly DateOnly Fecha = DateOnly.FromDateTime(DateTime.UtcNow).AddDays(7);

    private CitaService NuevoServicio(Infrastructure.Data.BarberiaDbContext context) =>
        new(context, slots, new FakeNotificationService(), new AdminUser(), new CreateCitaValidator(), Mapper, Clock);

    private async Task<(Guid Cliente, Guid Barbero, Guid Servicio)> SembrarAsync(Guid barberiaCliente, Guid barberiaBarbero, Guid barberiaServicio)
    {
        await using var seed = NewContext();
        var cliente = new Cliente { BarberiaId = barberiaCliente, Nombre = "Laura", Apellido = "Henao", Correo = "laura@correo.co" };
        var barbero = new Barbero { BarberiaId = barberiaBarbero, Nombre = "Julián", Apellido = "Restrepo", Disponible = true };
        var servicio = new Servicio { BarberiaId = barberiaServicio, Nombre = "Corte clásico", DuracionMinutos = 30, Precio = 35000 };
        seed.AddRange(cliente, barbero, servicio);
        seed.BarberoServicios.Add(new BarberoServicio { BarberoId = barbero.Id, ServicioId = servicio.Id, Activo = true });
        await seed.SaveChangesAsync();
        slots.ClienteQueReserva = cliente.Id;
        return (cliente.Id, barbero.Id, servicio.Id);
    }

    private static CreateCitaRequest Reserva((Guid Cliente, Guid Barbero, Guid Servicio) ids) => new()
    {
        ClienteId = ids.Cliente,
        BarberoId = ids.Barbero,
        ServicioId = ids.Servicio,
        FechaCita = Fecha,
        HoraInicio = new TimeOnly(10, 0),
        TokenRedisBloqueo = Token,
    };

    [Fact]
    public async Task La_cita_queda_en_la_barberia_de_su_barbero()
    {
        var ids = await SembrarAsync(barberiaA, barberiaA, barberiaA);
        await using var context = NewContext();

        var dto = await NuevoServicio(context).CrearCitaAsync(Reserva(ids), CancellationToken.None);

        await using var verify = NewContext();
        Assert.Equal(barberiaA, (await verify.Citas.SingleAsync(x => x.Id == dto.Id)).BarberiaId);
    }

    [Fact]
    public async Task Un_cliente_no_puede_reservar_en_otra_barberia()
    {
        var ids = await SembrarAsync(barberiaB, barberiaA, barberiaA);
        await using var context = NewContext();

        await Assert.ThrowsAsync<ValidationException>(() => NuevoServicio(context).CrearCitaAsync(Reserva(ids), CancellationToken.None));

        await using var verify = NewContext();
        Assert.Empty(await verify.Citas.ToListAsync());
    }

    [Fact]
    public async Task Una_cita_no_puede_usar_un_servicio_de_otra_barberia()
    {
        var ids = await SembrarAsync(barberiaA, barberiaA, barberiaB);
        await using var context = NewContext();

        await Assert.ThrowsAsync<ValidationException>(() => NuevoServicio(context).CrearCitaAsync(Reserva(ids), CancellationToken.None));

        await using var verify = NewContext();
        Assert.Empty(await verify.Citas.ToListAsync());
    }
}
