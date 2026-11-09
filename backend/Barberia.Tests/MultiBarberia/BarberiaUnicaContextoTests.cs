using Barberia.Application.Exceptions;
using Barberia.Infrastructure.Services;
using Barberia.Tests.Gestion;
using BarberiaEntity = Barberia.Domain.Entities.Barberia;

namespace Barberia.Tests.MultiBarberia;

// Mientras el token no trae la barbería (fase B), todo se crea en la barbería
// original del sistema: la más antigua.
public sealed class BarberiaUnicaContextoTests : GestionTestBase
{
    [Fact]
    public async Task Devuelve_la_barberia_mas_antigua()
    {
        // SaveChanges fija CreatedAt al guardar: la primera guardada es la más antigua.
        var original = new BarberiaEntity { Nombre = "BarberShop Medellín" };
        var nueva = new BarberiaEntity { Nombre = "Otra" };
        foreach (var barberia in new[] { original, nueva })
        {
            await using var seed = NewContext();
            seed.Barberias.Add(barberia);
            await seed.SaveChangesAsync();
            await Task.Delay(5);
        }

        await using var context = NewContext();
        var id = await new BarberiaUnicaContexto(context).ObtenerIdAsync(CancellationToken.None);

        Assert.Equal(original.Id, id);
    }

    [Fact]
    public async Task Sin_barberias_avisa_que_falta_configurarla()
    {
        await using var context = NewContext();

        var ex = await Assert.ThrowsAsync<ValidationException>(() => new BarberiaUnicaContexto(context).ObtenerIdAsync(CancellationToken.None));

        Assert.Equal("Todavía no hay una barbería configurada.", ex.Message);
    }
}
