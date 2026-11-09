using Barberia.Application.DTOs.Slots;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Services;
using Barberia.Domain.Entities;
using Barberia.Infrastructure.Data;
using Barberia.Shared.Constants;
using Barberia.Tests.Citas;
using Barberia.Tests.Reservas;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Time.Testing;

namespace Barberia.Tests.MultiBarberia;

// Los horarios apartados viven en Redis para todas las barberías juntas; recepción
// solo ve y libera los de los barberos de su barbería.
public sealed class ReservasEnCursoBarberiaTests
{
    private sealed class AdminDe(Guid barberiaId) : ICurrentUserService
    {
        public Guid? UserId => null;
        public Guid? ClienteId => null;
        public string Role => Roles.AdminBarberia;
        public bool IsAuthenticated => true;
        public bool IsAdmin => false;
        public bool IsAdminBarberia => true;
        public bool IsBarbero => false;
        public bool IsCliente => false;
        public Guid? BarberoId => null;
        public Guid? BarberiaId => barberiaId;
        public bool VeTodasLasBarberias => false;
    }

    private readonly string baseDeDatos = Guid.NewGuid().ToString();
    private readonly FakeTimeProvider clock = new(new DateTimeOffset(2026, 11, 7, 14, 0, 0, TimeSpan.Zero));
    private readonly FakeSlotBloqueoService slots = new();
    private readonly Guid barberiaA = Guid.NewGuid();
    private readonly Guid barberoA = Guid.NewGuid();
    private readonly Guid barberoB = Guid.NewGuid();
    private static readonly DateOnly Sabado = new(2026, 11, 7);

    private BarberiaDbContext Contexto(Guid barberiaId) =>
        new(new DbContextOptionsBuilder<BarberiaDbContext>().UseInMemoryDatabase(baseDeDatos).Options, new AdminDe(barberiaId));

    private ReservasEnCursoService Servicio() => new(Contexto(barberiaA), slots, new FakeNotificationService(), clock);

    private async Task SembrarAsync()
    {
        await using var seed = Contexto(barberiaA);
        seed.Barberos.Add(new Barbero { Id = barberoA, BarberiaId = barberiaA, Nombre = "Julián", Apellido = "A" });
        seed.Barberos.Add(new Barbero { Id = barberoB, BarberiaId = Guid.NewGuid(), Nombre = "Mateo", Apellido = "B" });
        await seed.SaveChangesAsync();

        var ahora = clock.GetUtcNow().UtcDateTime;
        foreach (var barbero in new[] { barberoA, barberoB })
        {
            slots.Bloqueos.Add(new BloqueoActivoDto(barbero, Sabado, new TimeOnly(15, 0), Guid.NewGuid(), ahora, ahora.AddMinutes(4)));
        }
    }

    [Fact]
    public async Task Recepcion_solo_ve_los_horarios_apartados_de_su_barberia()
    {
        await SembrarAsync();

        var reservas = await Servicio().ListarAsync(CancellationToken.None);

        Assert.Equal([barberoA], reservas.Select(x => x.BarberoId));
    }

    [Fact]
    public async Task Recepcion_no_puede_liberar_un_horario_de_otra_barberia()
    {
        await SembrarAsync();

        await Assert.ThrowsAsync<NotFoundException>(() => Servicio().LiberarAsync(
            new LiberarReservaRequest { BarberoId = barberoB, FechaCita = Sabado, HoraInicio = new TimeOnly(15, 0) },
            CancellationToken.None));

        Assert.Contains(slots.Bloqueos, x => x.BarberoId == barberoB);
    }
}
