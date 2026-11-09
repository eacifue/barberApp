using Barberia.Application.Services;
using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using Barberia.Shared.Constants;
using Barberia.Tests.Gestion;
using BarberiaEntity = Barberia.Domain.Entities.Barberia;

namespace Barberia.Tests.MultiBarberia;

// El SuperAdmin ve cómo va cada barbería en el mes en curso, en hora de Colombia.
// Mismas cuentas que el dashboard del panel: citas sin canceladas ni «no asistió»,
// e ingresos = lo cobrado (completadas).
public sealed class ResumenBarberiasTests : GestionTestBase
{
    private BarberiaService Servicio() => new(NewContext(), Mapper, null!, Clock);

    private async Task<Guid> SembrarAsync(string nombre, params (DateOnly Fecha, EstadoCita Estado, decimal Precio)[] citas)
    {
        await using var db = NewContext();
        var barberia = new BarberiaEntity { Nombre = nombre, Activa = true };
        var barbero = new Barbero { BarberiaId = barberia.Id, Nombre = "Julián", Apellido = "R" };
        var cliente = new Cliente { BarberiaId = barberia.Id, Rol = Roles.Cliente, Nombre = "Laura", Apellido = "H", Correo = $"{Guid.NewGuid():N}@correo.co" };
        db.AddRange(barberia, barbero, cliente);
        db.Barberos.Add(new Barbero { BarberiaId = barberia.Id, Nombre = "Mateo", Apellido = "L", Activo = false });
        db.Clientes.Add(new Cliente { BarberiaId = barberia.Id, Rol = Roles.AdminBarberia, Nombre = "Sara", Apellido = "G", Correo = $"{Guid.NewGuid():N}@correo.co" });
        foreach (var (fecha, estado, precio) in citas)
        {
            db.Citas.Add(new Cita { BarberiaId = barberia.Id, ClienteId = cliente.Id, BarberoId = barbero.Id, FechaCita = fecha, Estado = estado, PrecioFinal = precio });
        }

        await db.SaveChangesAsync();
        return barberia.Id;
    }

    [Fact]
    public async Task Cada_barberia_muestra_sus_citas_ingresos_clientes_y_barberos_del_mes()
    {
        // Reloj: 7 nov 2026, 9:00 a. m. en Medellín.
        var a = await SembrarAsync(
            "Barbería A",
            (new DateOnly(2026, 11, 3), EstadoCita.Completada, 35000),
            (new DateOnly(2026, 11, 5), EstadoCita.Completada, 50000),
            (new DateOnly(2026, 11, 20), EstadoCita.Pendiente, 35000),
            (new DateOnly(2026, 11, 6), EstadoCita.Cancelada, 35000),
            (new DateOnly(2026, 11, 6), EstadoCita.NoShow, 35000),
            (new DateOnly(2026, 10, 31), EstadoCita.Completada, 99000));
        var b = await SembrarAsync("Barbería B", (new DateOnly(2026, 11, 2), EstadoCita.Completada, 20000));

        var resumen = await Servicio().ResumenAsync(CancellationToken.None);

        var deA = Assert.Single(resumen, x => x.BarberiaId == a);
        Assert.Equal("Barbería A", deA.Nombre);
        Assert.Equal(3, deA.CitasMes);
        Assert.Equal(85000m, deA.IngresosMes);
        Assert.Equal(1, deA.Clientes);
        Assert.Equal(1, deA.BarberosActivos);
        var deB = Assert.Single(resumen, x => x.BarberiaId == b);
        Assert.Equal(1, deB.CitasMes);
        Assert.Equal(20000m, deB.IngresosMes);
    }

    [Fact]
    public async Task El_mes_se_cuenta_en_hora_de_Colombia_no_en_UTC()
    {
        // 1 dic 2026, 3:00 a. m. UTC = 30 nov, 10:00 p. m. en Medellín: todavía es noviembre.
        Clock.SetUtcNow(new DateTimeOffset(2026, 12, 1, 3, 0, 0, TimeSpan.Zero));
        var a = await SembrarAsync(
            "Barbería A",
            (new DateOnly(2026, 11, 30), EstadoCita.Completada, 35000),
            (new DateOnly(2026, 12, 1), EstadoCita.Pendiente, 35000));

        var deA = Assert.Single(await Servicio().ResumenAsync(CancellationToken.None), x => x.BarberiaId == a);

        Assert.Equal(1, deA.CitasMes);
        Assert.Equal(35000m, deA.IngresosMes);
    }
}
