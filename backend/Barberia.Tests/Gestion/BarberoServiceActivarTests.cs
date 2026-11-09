using Barberia.Application.Exceptions;
using Barberia.Application.Services;
using Barberia.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.Gestion;

public class BarberoServiceActivarTests : GestionTestBase
{
    private BarberoService NewService(Barberia.Infrastructure.Data.BarberiaDbContext context) => new(context, Mapper, null!, null!, null!);

    [Fact]
    public async Task Activar_BarberoDesactivado_QuedaActivoYDisponibleSinRecuperarServicios()
    {
        Guid barberoId;
        await using (var seed = NewContext())
        {
            var servicio = new Servicio { Nombre = "Corte clásico", DuracionMinutos = 30, Precio = 35000 };
            var barbero = new Barbero { Nombre = "Julián", Apellido = "Restrepo", Activo = false, Disponible = false };
            seed.Servicios.Add(servicio);
            seed.Barberos.Add(barbero);
            seed.BarberoServicios.Add(new BarberoServicio { BarberoId = barbero.Id, ServicioId = servicio.Id, Activo = false });
            await seed.SaveChangesAsync();
            barberoId = barbero.Id;
        }

        await using var context = NewContext();
        var dto = await NewService(context).ActivarAsync(barberoId, CancellationToken.None);

        Assert.Equal(barberoId, dto.Id);
        await using var verify = NewContext();
        var guardado = await verify.Barberos.IgnoreQueryFilters().SingleAsync(x => x.Id == barberoId);
        Assert.True(guardado.Activo);
        Assert.True(guardado.Disponible);
        // Los servicios no se adivinan: se confirman al editar el barbero.
        Assert.False(await verify.BarberoServicios.AnyAsync(x => x.BarberoId == barberoId && x.Activo));
    }

    [Fact]
    public async Task Activar_BarberoInexistente_DevuelveNoEncontrado()
    {
        await using var context = NewContext();

        await Assert.ThrowsAsync<NotFoundException>(() => NewService(context).ActivarAsync(Guid.NewGuid(), CancellationToken.None));
    }
}
