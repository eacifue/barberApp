using Barberia.Application.Services;
using Barberia.Domain.Entities;

namespace Barberia.Tests.Gestion;

// El panel necesita ver los desactivados para poder reactivarlos; la app no.
public class ListadosConInactivosTests : GestionTestBase
{
    private async Task SeedAsync()
    {
        await using var context = NewContext();
        context.Servicios.AddRange(
            new Servicio { Nombre = "Corte", DuracionMinutos = 30, Precio = 25000 },
            new Servicio { Nombre = "Tinte", DuracionMinutos = 90, Precio = 50000, Activo = false });
        context.Barberos.AddRange(
            new Barbero { Nombre = "Julián", Apellido = "Restrepo" },
            new Barbero { Nombre = "Mateo", Apellido = "López", Activo = false, Disponible = false });
        await context.SaveChangesAsync();
    }

    [Fact]
    public async Task Servicios_PorDefectoSoloActivos_ConElParametroTambienInactivos()
    {
        await SeedAsync();
        await using var context = NewContext();
        var service = new ServicioService(context, Mapper, null!, null!);

        var publico = await service.GetAllByBarberiaAsync(Guid.NewGuid(), CancellationToken.None);
        var panel = await service.GetAllByBarberiaAsync(Guid.NewGuid(), CancellationToken.None, incluirInactivos: true);

        Assert.Equal(["Corte"], publico.Select(s => s.Nombre));
        Assert.Equal(["Corte", "Tinte"], panel.Select(s => s.Nombre));
    }

    [Fact]
    public async Task Barberos_PorDefectoSoloActivos_ConElParametroTambienInactivos()
    {
        await SeedAsync();
        await using var context = NewContext();
        var service = new BarberoService(context, Mapper, null!, null!, null!);

        var publico = await service.GetAllByBarberiaAsync(Guid.NewGuid(), CancellationToken.None);
        var panel = await service.GetAllByBarberiaAsync(Guid.NewGuid(), CancellationToken.None, incluirInactivos: true);

        Assert.Equal(["Julián"], publico.Select(b => b.Nombre));
        Assert.Equal(["Julián", "Mateo"], panel.Select(b => b.Nombre));
    }
}
