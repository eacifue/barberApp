using Barberia.Application.Exceptions;
using Barberia.Application.Services;
using Barberia.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.Gestion;

public class ServicioServiceActivarTests : GestionTestBase
{
    private ServicioService NewService(Barberia.Infrastructure.Data.BarberiaDbContext context) => new(context, Mapper, null!);

    private async Task<Guid> SeedServicioAsync(bool activo)
    {
        await using var context = NewContext();
        var s = new Servicio { Nombre = "Corte clásico", DuracionMinutos = 30, Precio = 35000, Activo = activo };
        context.Servicios.Add(s);
        await context.SaveChangesAsync();
        return s.Id;
    }

    [Fact]
    public async Task Activar_ServicioDesactivado_VuelveAEstarActivo()
    {
        var id = await SeedServicioAsync(activo: false);
        await using var context = NewContext();

        var dto = await NewService(context).ActivarAsync(id, CancellationToken.None);

        Assert.Equal(id, dto.Id);
        await using var verify = NewContext();
        Assert.True((await verify.Servicios.IgnoreQueryFilters().SingleAsync(x => x.Id == id)).Activo);
    }

    [Fact]
    public async Task Activar_ServicioInexistente_DevuelveNoEncontrado()
    {
        await using var context = NewContext();

        await Assert.ThrowsAsync<NotFoundException>(() => NewService(context).ActivarAsync(Guid.NewGuid(), CancellationToken.None));
    }
}
