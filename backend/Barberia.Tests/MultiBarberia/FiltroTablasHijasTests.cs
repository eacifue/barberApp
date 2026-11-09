using Barberia.Application.Interfaces.Services;
using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using Barberia.Infrastructure.Data;
using Barberia.Shared.Constants;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.MultiBarberia;

// Las tablas sin columna BarberiaId se filtran por su padre (barbero o cliente):
// quien trabaja en la barbería A no ve filas de la B aunque consulte la tabla directo.
public sealed class FiltroTablasHijasTests
{
    private sealed class Usuario(Guid? barberiaId, bool todas) : ICurrentUserService
    {
        public Guid? UserId => null;
        public Guid? ClienteId => null;
        public string Role => todas ? Roles.Admin : Roles.AdminBarberia;
        public bool IsAuthenticated => true;
        public bool IsAdmin => todas;
        public bool IsAdminBarberia => !todas;
        public bool IsBarbero => false;
        public bool IsCliente => false;
        public Guid? BarberoId => null;
        public Guid? BarberiaId => barberiaId;
        public bool VeTodasLasBarberias => todas;
    }

    private readonly string baseDeDatos = Guid.NewGuid().ToString();
    private readonly Guid barberiaA = Guid.NewGuid();
    private readonly Guid barberiaB = Guid.NewGuid();

    private BarberiaDbContext Contexto(ICurrentUserService usuario) =>
        new(new DbContextOptionsBuilder<BarberiaDbContext>().UseInMemoryDatabase(baseDeDatos).Options, usuario);

    private async Task SembrarAsync(Guid barberiaId)
    {
        await using var db = Contexto(new Usuario(null, todas: true));
        var barbero = new Barbero { BarberiaId = barberiaId, Nombre = "Julián", Apellido = "R" };
        var servicio = new Servicio { BarberiaId = barberiaId, Nombre = "Corte", DuracionMinutos = 30, Precio = 1 };
        var cliente = new Cliente { BarberiaId = barberiaId, Nombre = "Laura", Apellido = "H", Correo = $"{Guid.NewGuid()}@correo.co" };
        var cita = new Cita { BarberiaId = barberiaId, ClienteId = cliente.Id, BarberoId = barbero.Id, ServicioId = servicio.Id, Estado = EstadoCita.Completada };
        db.AddRange(barbero, servicio, cliente, cita);
        db.AddRange(
            new BarberoServicio { BarberoId = barbero.Id, ServicioId = servicio.Id },
            new HorarioSemana { BarberoId = barbero.Id, DiaSemana = DiaSemana.Lunes },
            new BloqueoHorario { BarberoId = barbero.Id },
            new BarberAvailability { BarberId = barbero.Id },
            new BarberDayOff { BarberId = barbero.Id },
            new Review { CitaId = cita.Id, ClienteId = cliente.Id, BarberoId = barbero.Id, Calificacion = 5 },
            new CodigoRecuperacion { ClienteId = cliente.Id, CodigoHash = "x" });
        await db.SaveChangesAsync();
    }

    private static async Task<int[]> ContarAsync(BarberiaDbContext db) =>
    [
        await db.BarberoServicios.CountAsync(),
        await db.HorariosSemana.CountAsync(),
        await db.BloqueosHorario.CountAsync(),
        await db.BarberAvailabilities.CountAsync(),
        await db.BarberDaysOff.CountAsync(),
        await db.Reviews.CountAsync(),
        await db.CodigosRecuperacion.CountAsync(),
    ];

    [Fact]
    public async Task Quien_trabaja_en_una_barberia_solo_ve_las_filas_hijas_de_esa_barberia()
    {
        await SembrarAsync(barberiaA);
        await SembrarAsync(barberiaB);

        await using var comoA = Contexto(new Usuario(barberiaA, todas: false));
        await using var comoSuperAdmin = Contexto(new Usuario(null, todas: true));

        var deA = await ContarAsync(comoA);
        var todas = await ContarAsync(comoSuperAdmin);

        Assert.Equal(new[] { 1, 1, 1, 1, 1, 1, 1 }, deA);
        Assert.Equal(new[] { 2, 2, 2, 2, 2, 2, 2 }, todas);
    }
}
