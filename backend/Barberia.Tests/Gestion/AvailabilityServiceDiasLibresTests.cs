using Barberia.Application.Exceptions;
using Barberia.Application.Services;
using Barberia.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.Gestion;

// Reloj de la base: 7 nov 2026, 9:00 a. m. en Medellín (14:00 UTC).
public class AvailabilityServiceDiasLibresTests : GestionTestBase
{
    private readonly Guid barberoId = Guid.NewGuid();
    private readonly Guid otroBarberoId = Guid.NewGuid();

    private AvailabilityService NewService(Barberia.Infrastructure.Data.BarberiaDbContext context) => new(context, null!, Clock);

    private async Task<Dictionary<string, Guid>> SeedAsync()
    {
        await using var context = NewContext();
        context.Barberos.Add(new Barbero { Id = barberoId, Nombre = "Julián", Apellido = "Restrepo" });
        context.Barberos.Add(new Barbero { Id = otroBarberoId, Nombre = "Mateo", Apellido = "López" });
        var dias = new Dictionary<string, BarberDayOff>
        {
            ["ayer"] = new() { BarberId = barberoId, Date = new DateOnly(2026, 11, 6), Reason = "Diligencia" },
            ["hoy"] = new() { BarberId = barberoId, Date = new DateOnly(2026, 11, 7), Reason = "Cita médica" },
            ["diciembre"] = new() { BarberId = barberoId, Date = new DateOnly(2026, 12, 18), Reason = null },
            ["vacaciones"] = new() { BarberId = barberoId, Date = new DateOnly(2026, 11, 23), Reason = "Vacaciones" },
            ["quitado"] = new() { BarberId = barberoId, Date = new DateOnly(2026, 11, 24), Activo = false },
            ["otro"] = new() { BarberId = otroBarberoId, Date = new DateOnly(2026, 11, 10) },
        };
        context.BarberDaysOff.AddRange(dias.Values);
        await context.SaveChangesAsync();
        return dias.ToDictionary(x => x.Key, x => x.Value.Id);
    }

    [Fact]
    public async Task DiasLibres_DevuelveDesdeHoyEnOrdenSoloActivosDelBarbero()
    {
        var ids = await SeedAsync();
        await using var context = NewContext();

        var dias = await NewService(context).GetDaysOffAsync(barberoId, CancellationToken.None);

        Assert.Equal([ids["hoy"], ids["vacaciones"], ids["diciembre"]], dias.Select(d => d.Id));
        Assert.Equal("Vacaciones", dias[1].Reason);
    }

    [Fact]
    public async Task DiasLibres_UsaLaFechaDeMedellinNoLaUtc()
    {
        var ids = await SeedAsync();
        // 6 nov, 9:30 p. m. en Medellín = 7 nov 02:30 UTC: «ayer» (6 nov) todavía es hoy.
        var clockTemprano = new Microsoft.Extensions.Time.Testing.FakeTimeProvider(new DateTimeOffset(2026, 11, 7, 2, 30, 0, TimeSpan.Zero));
        await using var context = NewContext();

        var dias = await new AvailabilityService(context, null!, clockTemprano).GetDaysOffAsync(barberoId, CancellationToken.None);

        Assert.Equal(ids["ayer"], dias[0].Id);
    }

    [Fact]
    public async Task QuitarDiaLibre_DejaDeAparecerEnLaLista()
    {
        var ids = await SeedAsync();
        await using (var context = NewContext())
        {
            await NewService(context).RemoveDayOffAsync(barberoId, ids["vacaciones"], CancellationToken.None);
        }

        await using var verify = NewContext();
        var dias = await NewService(verify).GetDaysOffAsync(barberoId, CancellationToken.None);
        Assert.DoesNotContain(dias, d => d.Id == ids["vacaciones"]);
        Assert.False((await verify.BarberDaysOff.IgnoreQueryFilters().SingleAsync(x => x.Id == ids["vacaciones"])).Activo);
    }

    [Fact]
    public async Task QuitarDiaLibre_DeOtroBarbero_DevuelveNoEncontradoYNoLoToca()
    {
        var ids = await SeedAsync();
        await using var context = NewContext();

        await Assert.ThrowsAsync<NotFoundException>(() => NewService(context).RemoveDayOffAsync(barberoId, ids["otro"], CancellationToken.None));

        await using var verify = NewContext();
        Assert.True((await verify.BarberDaysOff.IgnoreQueryFilters().SingleAsync(x => x.Id == ids["otro"])).Activo);
    }
}
