using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Barberia.Application.DTOs.Auth;
using Barberia.Domain.Entities;
using Barberia.Shared;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.Http;

// Registro y login sin sesión. La app de clientes manda su barbería; el panel
// (administrador, barbero, SuperAdmin) entra sin elegirla.
public sealed class AuthHttpTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    private HttpClient Anonimo(Guid? barberia = null)
    {
        var http = api.CreateClient();
        if (barberia is { } id) http.DefaultRequestHeaders.Add("X-Barberia-Id", id.ToString());
        return http;
    }

    private static object Registro(string correo) => new { nombre = "Laura", apellido = "Henao", telefono = "3011419610", correo, password = "secreta1" };

    private static object Login(string correo, string password = "secreta1") => new { correo, password };

    private static async Task<AuthResponseDto> SesionAsync(HttpResponseMessage respuesta)
    {
        Assert.True(respuesta.IsSuccessStatusCode, $"{(int)respuesta.StatusCode}: {await respuesta.Content.ReadAsStringAsync()}");
        return (await respuesta.Content.ReadFromJsonAsync<ApiResponse<AuthResponseDto>>(Json))!.Data!;
    }

    [Fact]
    public async Task Registrarse_desde_la_app_deja_al_cliente_en_su_barberia()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);
        var correo = $"{Guid.NewGuid():N}@correo.co";

        var sesion = await SesionAsync(await Anonimo(a.Id).PostAsJsonAsync("/api/v1/auth/registro", Registro(correo)));

        var cuenta = await api.ConBaseAsync(db => db.Clientes.IgnoreQueryFilters().SingleAsync(x => x.Id == sesion.ClienteId));
        Assert.Equal(a.Id, cuenta.BarberiaId);
    }

    [Fact]
    public async Task Registrarse_sin_barberia_pide_elegirla()
    {
        var respuesta = await Anonimo().PostAsJsonAsync("/api/v1/auth/registro", Registro($"{Guid.NewGuid():N}@correo.co"));

        Assert.Equal(HttpStatusCode.BadRequest, respuesta.StatusCode);
        Assert.Contains("Elige la barbería", await respuesta.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task Desde_la_app_el_login_entra_a_la_cuenta_de_esa_barberia()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var correo = $"{Guid.NewGuid():N}@correo.co";
        await SesionAsync(await Anonimo(a.Id).PostAsJsonAsync("/api/v1/auth/registro", Registro(correo)));
        await SesionAsync(await Anonimo(b.Id).PostAsJsonAsync("/api/v1/auth/registro", Registro(correo)));

        var sesion = await SesionAsync(await Anonimo(b.Id).PostAsJsonAsync("/api/v1/auth/login", Login(correo)));

        var cuenta = await api.ConBaseAsync(db => db.Clientes.IgnoreQueryFilters().SingleAsync(x => x.Id == sesion.ClienteId));
        Assert.Equal(b.Id, cuenta.BarberiaId);
    }

    [Fact]
    public async Task Desde_el_panel_el_admin_entra_sin_elegir_barberia()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);

        var sesion = await SesionAsync(await Anonimo().PostAsJsonAsync("/api/v1/auth/login", Login(a.Admin.Correo)));

        Assert.Equal(a.Admin.Id, sesion.ClienteId);
    }

    [Fact]
    public async Task Sin_barberia_y_con_cuentas_en_dos_barberias_pide_elegirla()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var correo = $"{Guid.NewGuid():N}@correo.co";
        await SesionAsync(await Anonimo(a.Id).PostAsJsonAsync("/api/v1/auth/registro", Registro(correo)));
        await SesionAsync(await Anonimo(b.Id).PostAsJsonAsync("/api/v1/auth/registro", Registro(correo)));

        var respuesta = await Anonimo().PostAsJsonAsync("/api/v1/auth/login", Login(correo));

        Assert.Equal(HttpStatusCode.BadRequest, respuesta.StatusCode);
        Assert.Contains("Elige tu barbería", await respuesta.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task Sin_barberia_una_contrasena_equivocada_no_entra()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);

        var respuesta = await Anonimo().PostAsJsonAsync("/api/v1/auth/login", Login(a.Admin.Correo, "otra-clave"));

        Assert.Equal(HttpStatusCode.Unauthorized, respuesta.StatusCode);
    }
}
