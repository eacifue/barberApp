using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Barberia.Application.DTOs.Servicios;
using Barberia.Shared;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.Http;

// Sin sesión (catálogo, disponibilidad), la barbería viaja en la ruta o en el
// header X-Barberia-Id. Solo se ve esa barbería, y tiene que existir y estar activa.
public sealed class RutasPublicasHttpTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    private HttpClient Anonimo(Guid? barberia = null)
    {
        var http = api.CreateClient();
        if (barberia is { } id) http.DefaultRequestHeaders.Add("X-Barberia-Id", id.ToString());
        return http;
    }

    [Fact]
    public async Task El_catalogo_de_una_barberia_solo_trae_sus_servicios()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);

        var respuesta = await Anonimo().GetAsync($"/api/v1/barberias/{a.Id}/servicios");

        Assert.Equal(HttpStatusCode.OK, respuesta.StatusCode);
        var ids = (await respuesta.Content.ReadFromJsonAsync<ApiResponse<List<ServicioDto>>>(Json))!.Data!.Select(x => x.Id).ToList();
        Assert.Contains(a.Servicio.Id, ids);
        Assert.DoesNotContain(b.Servicio.Id, ids);
    }

    public static TheoryData<string> RutasDeOtraBarberia => new()
    {
        "/api/v1/barberos/{barbero}",
        "/api/v1/barberos/{barbero}/horarios",
        "/api/v1/barberos/{barbero}/servicios",
        "/api/v1/servicios/{servicio}",
        "/api/v1/barberos/{barbero}/disponibilidad?servicioId={servicio}&fecha={fecha}",
    };

    [Theory]
    [MemberData(nameof(RutasDeOtraBarberia))]
    public async Task Desde_una_barberia_no_se_ve_nada_de_otra(string plantilla)
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var ruta = plantilla
            .Replace("{barbero}", b.Barbero.Id.ToString())
            .Replace("{servicio}", b.Servicio.Id.ToString())
            // La disponibilidad solo acepta fechas entre hoy y 30 días adelante.
            .Replace("{fecha}", DateOnly.FromDateTime(DateTime.UtcNow).AddDays(7).ToString("yyyy-MM-dd"));

        var respuesta = await Anonimo(a.Id).GetAsync(ruta);

        Assert.Equal(HttpStatusCode.NotFound, respuesta.StatusCode);
    }

    [Fact]
    public async Task Sin_barberia_no_se_ve_ningun_barbero()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);

        var respuesta = await Anonimo().GetAsync($"/api/v1/barberos/{a.Barbero.Id}");

        Assert.Equal(HttpStatusCode.NotFound, respuesta.StatusCode);
    }

    [Fact]
    public async Task Una_barberia_inactiva_o_inexistente_responde_404()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);
        await api.ConBaseAsync(db => db.Barberias.Where(x => x.Id == a.Id).ExecuteUpdateAsync(s => s.SetProperty(x => x.Activa, false)));

        var inactiva = await Anonimo().GetAsync($"/api/v1/barberias/{a.Id}/servicios");
        var inexistente = await Anonimo(Guid.NewGuid()).GetAsync($"/api/v1/barberos/{a.Barbero.Id}");

        Assert.Equal(HttpStatusCode.NotFound, inactiva.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, inexistente.StatusCode);
    }
}
