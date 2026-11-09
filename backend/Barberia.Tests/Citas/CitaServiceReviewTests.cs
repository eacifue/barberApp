using AutoMapper;
using Barberia.Application.DTOs.Citas;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Mappings.Barberia;
using Barberia.Application.Services;
using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using Barberia.Infrastructure.Data;
using Barberia.Shared.Constants;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.Citas;

// Pruebas de servicio sobre EF Core InMemory: cubren reglas de negocio
// independientes del proveedor (propiedad, estado, duplicado, rangos).
// No prueban el índice único relacional de reviews.CitaId (eso lo garantiza Postgres).
public class CitaServiceReviewTests : CitaServiceTestBase
{
    [Fact]
    public async Task CrearReview_CitaCompletadaDelCliente_GuardaLaResenaConElBarberoDeLaCita()
    {
        var citaId = await SeedCitaAsync(EstadoCita.Completada);
        await using var context = NewContext(clienteId);
        var service = NewService(context, clienteId);

        var review = await service.CrearReviewAsync(citaId, new CrearReviewRequest { Calificacion = 4, Comentario = "Muy bien" }, CancellationToken.None);

        Assert.Equal(citaId, review.CitaId);
        Assert.Equal(barberoId, review.BarberoId);
        Assert.Equal(4, review.Calificacion);
        Assert.Equal("Muy bien", review.Comentario);

        await using var verify = NewContext(clienteId);
        var stored = await verify.Reviews.IgnoreQueryFilters().SingleAsync();
        Assert.Equal(clienteId, stored.ClienteId);
        Assert.Equal(barberoId, stored.BarberoId);
        Assert.Equal(4, stored.Calificacion);
        Assert.True(stored.Visible);
    }

    [Theory]
    [InlineData(EstadoCita.Pendiente)]
    [InlineData(EstadoCita.Confirmada)]
    [InlineData(EstadoCita.EnProgreso)]
    [InlineData(EstadoCita.Cancelada)]
    [InlineData(EstadoCita.NoShow)]
    public async Task CrearReview_CitaNoCompletada_RechazaConConflicto(EstadoCita estado)
    {
        var citaId = await SeedCitaAsync(estado);
        await using var context = NewContext(clienteId);
        var service = NewService(context, clienteId);

        var ex = await Assert.ThrowsAsync<Barberia.Application.Exceptions.ConflictException>(() =>
            service.CrearReviewAsync(citaId, new CrearReviewRequest { Calificacion = 5 }, CancellationToken.None));

        Assert.Equal("Solo puedes calificar citas completadas.", ex.Message);
        await using var verify = NewContext(clienteId);
        Assert.False(await verify.Reviews.IgnoreQueryFilters().AnyAsync());
    }

    [Fact]
    public async Task CrearReview_CitaDeOtroCliente_RechazaSinGuardar()
    {
        var citaAjena = await SeedCitaAsync(EstadoCita.Completada, owner: otroClienteId);
        await using var context = NewContext(clienteId);
        var service = NewService(context, clienteId);

        await Assert.ThrowsAsync<Barberia.Application.Exceptions.UnauthorizedException>(() =>
            service.CrearReviewAsync(citaAjena, new CrearReviewRequest { Calificacion = 1 }, CancellationToken.None));

        await using var verify = NewContext(clienteId);
        Assert.False(await verify.Reviews.IgnoreQueryFilters().AnyAsync());
    }

    [Fact]
    public async Task CrearReview_CitaInexistente_DevuelveNoEncontrada()
    {
        await SeedCitaAsync(EstadoCita.Completada);
        await using var context = NewContext(clienteId);
        var service = NewService(context, clienteId);

        await Assert.ThrowsAsync<Barberia.Application.Exceptions.NotFoundException>(() =>
            service.CrearReviewAsync(Guid.NewGuid(), new CrearReviewRequest { Calificacion = 5 }, CancellationToken.None));
    }

    [Fact]
    public async Task CrearReview_CitaYaCalificada_RechazaLaSegundaResena()
    {
        var citaId = await SeedCitaAsync(EstadoCita.Completada);
        await using (var first = NewContext(clienteId))
        {
            await NewService(first, clienteId).CrearReviewAsync(citaId, new CrearReviewRequest { Calificacion = 5 }, CancellationToken.None);
        }

        await using var context = NewContext(clienteId);
        var ex = await Assert.ThrowsAsync<Barberia.Application.Exceptions.ConflictException>(() =>
            NewService(context, clienteId).CrearReviewAsync(citaId, new CrearReviewRequest { Calificacion = 2 }, CancellationToken.None));

        Assert.Equal("Ya calificaste esta cita.", ex.Message);
        await using var verify = NewContext(clienteId);
        var stored = await verify.Reviews.IgnoreQueryFilters().SingleAsync();
        Assert.Equal(5, stored.Calificacion);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(6)]
    public async Task CrearReview_CalificacionFueraDeRango_RechazaConValidacion(int calificacion)
    {
        var citaId = await SeedCitaAsync(EstadoCita.Completada);
        await using var context = NewContext(clienteId);

        var ex = await Assert.ThrowsAsync<Barberia.Application.Exceptions.ValidationException>(() =>
            NewService(context, clienteId).CrearReviewAsync(citaId, new CrearReviewRequest { Calificacion = calificacion }, CancellationToken.None));

        Assert.Contains("La calificación debe estar entre 1 y 5 estrellas.", ex.Errors);
        await using var verify = NewContext(clienteId);
        Assert.False(await verify.Reviews.IgnoreQueryFilters().AnyAsync());
    }

    [Fact]
    public async Task CrearReview_ComentarioDeMasDe500Caracteres_RechazaConValidacion()
    {
        var citaId = await SeedCitaAsync(EstadoCita.Completada);
        await using var context = NewContext(clienteId);

        var ex = await Assert.ThrowsAsync<Barberia.Application.Exceptions.ValidationException>(() =>
            NewService(context, clienteId).CrearReviewAsync(citaId, new CrearReviewRequest { Calificacion = 4, Comentario = new string('a', 501) }, CancellationToken.None));

        Assert.Contains("El comentario puede tener máximo 500 caracteres.", ex.Errors);
    }

    [Fact]
    public async Task CrearReview_ComentarioEnBlanco_SeGuardaSinComentario()
    {
        var citaId = await SeedCitaAsync(EstadoCita.Completada);
        await using var context = NewContext(clienteId);

        var review = await NewService(context, clienteId).CrearReviewAsync(citaId, new CrearReviewRequest { Calificacion = 5, Comentario = "   " }, CancellationToken.None);

        Assert.Null(review.Comentario);
    }

    [Fact]
    public async Task MisCitas_IndicaSiCadaCitaYaTieneResena()
    {
        var calificada = await SeedCitaAsync(EstadoCita.Completada);
        var pendiente = await SeedCitaAsync(EstadoCita.Completada);
        await using (var write = NewContext(clienteId))
        {
            await NewService(write, clienteId).CrearReviewAsync(calificada, new CrearReviewRequest { Calificacion = 5 }, CancellationToken.None);
        }

        await using var context = NewContext(clienteId);
        var service = NewService(context, clienteId);
        var citas = await service.GetByClienteAsync(clienteId, CancellationToken.None);
        var detalle = await service.GetByIdAsync(calificada, CancellationToken.None);

        Assert.True(citas.Single(x => x.Id == calificada).TieneReview);
        Assert.False(citas.Single(x => x.Id == pendiente).TieneReview);
        Assert.True(detalle.TieneReview);
    }
}
