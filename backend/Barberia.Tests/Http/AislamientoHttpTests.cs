using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Barberia.Application.DTOs.Clientes;
using Barberia.Application.DTOs.Servicios;
using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Barberia.Shared;

namespace Barberia.Tests.Http;

// Un usuario de la barbería A no ve ni toca nada de la barbería B.
// Se prueba por HTTP: token, middleware, autorización y filtros de EF juntos.
public sealed class AislamientoHttpTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    private static async Task<T> DataAsync<T>(HttpResponseMessage respuesta, HttpStatusCode esperado = HttpStatusCode.OK)
    {
        Assert.True(respuesta.StatusCode == esperado, $"{(int)respuesta.StatusCode}: {await respuesta.Content.ReadAsStringAsync()}");
        var cuerpo = await respuesta.Content.ReadFromJsonAsync<ApiResponse<T>>(Json);
        return cuerpo!.Data!;
    }

    [Fact]
    public async Task El_admin_de_una_barberia_solo_ve_sus_clientes()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var http = api.ComoUsuario(a.Admin);

        var clientes = await DataAsync<List<ClienteDto>>(await http.GetAsync("/api/v1/clientes"));

        var ids = clientes.Select(x => x.Id).ToList();
        Assert.Contains(a.Cliente.Id, ids);
        Assert.DoesNotContain(b.Cliente.Id, ids);
        Assert.DoesNotContain(b.Admin.Id, ids);
    }

    public static TheoryData<string> RutasDeDetalle => new()
    {
        "/api/v1/citas/{cita}",
        "/api/v1/admin/clientes/{cliente}",
        "/api/v1/servicios/{servicio}",
        "/api/v1/barberos/{barbero}",
        "/api/v1/barbers/{barbero}/day-off",
        "/api/v1/barbers/{barbero}/availability",
        "/api/v1/barberos/{barbero}/citas",
    };

    private static string Ruta(string plantilla, BarberiaSembrada x) => plantilla
        .Replace("{cita}", x.Cita.Id.ToString())
        .Replace("{cliente}", x.Cliente.Id.ToString())
        .Replace("{servicio}", x.Servicio.Id.ToString())
        .Replace("{barbero}", x.Barbero.Id.ToString());

    [Theory]
    [MemberData(nameof(RutasDeDetalle))]
    public async Task Pedir_por_id_algo_de_otra_barberia_responde_404(string plantilla)
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var http = api.ComoUsuario(a.Admin);

        var propia = await http.GetAsync(Ruta(plantilla, a));
        var ajena = await http.GetAsync(Ruta(plantilla, b));

        Assert.Equal(HttpStatusCode.OK, propia.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, ajena.StatusCode);
    }

    public static TheoryData<string, string> EscriturasSobreOtraBarberia => new()
    {
        { "PUT", "/api/v1/servicios/{servicio}/activar" },
        { "DELETE", "/api/v1/servicios/{servicio}" },
        { "PUT", "/api/v1/barberos/{barbero}/activar" },
        { "DELETE", "/api/v1/barberos/{barbero}" },
        { "PUT", "/api/v1/citas/{cita}/confirmar" },
        { "DELETE", "/api/v1/admin/clientes/{cliente}" },
        { "DELETE", "/api/v1/users/{cliente}" },
    };

    [Theory]
    [MemberData(nameof(EscriturasSobreOtraBarberia))]
    public async Task Escribir_sobre_algo_de_otra_barberia_responde_404_y_no_lo_cambia(string metodo, string plantilla)
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        // Inactivos en B: así «activar» tendría algo que cambiar si se colara.
        await api.ConBaseAsync(async db =>
        {
            await db.Servicios.IgnoreQueryFilters().Where(x => x.Id == b.Servicio.Id).ExecuteUpdateAsync(s => s.SetProperty(x => x.Activo, false));
            return await db.Barberos.IgnoreQueryFilters().Where(x => x.Id == b.Barbero.Id).ExecuteUpdateAsync(s => s.SetProperty(x => x.Activo, false));
        });
        var antes = await EstadoDeAsync(b);
        var http = api.ComoUsuario(a.Admin);

        var respuesta = await http.SendAsync(new HttpRequestMessage(new HttpMethod(metodo), Ruta(plantilla, b)));

        Assert.Equal(HttpStatusCode.NotFound, respuesta.StatusCode);
        Assert.Equal(antes, await EstadoDeAsync(b));
    }

    private Task<string> EstadoDeAsync(BarberiaSembrada x) => api.ConBaseAsync(async db =>
        $"servicio={(await db.Servicios.IgnoreQueryFilters().SingleAsync(s => s.Id == x.Servicio.Id)).Activo} " +
        $"barbero={(await db.Barberos.IgnoreQueryFilters().SingleAsync(s => s.Id == x.Barbero.Id)).Activo} " +
        $"cita={(await db.Citas.IgnoreQueryFilters().SingleAsync(s => s.Id == x.Cita.Id)).Estado} " +
        $"cliente={(await db.Clientes.IgnoreQueryFilters().SingleAsync(s => s.Id == x.Cliente.Id)).Activo}");

    [Theory]
    [InlineData("AdministradorBarberia", "/api/v1/clientes")]
    [InlineData("Cliente", "/api/v1/citas/mis-citas")]
    public async Task Un_token_sin_barberia_de_antes_del_cambio_pide_iniciar_sesion_de_nuevo(string rol, string ruta)
    {
        var (a, _) = await DosBarberias.CrearAsync(api);
        var cuenta = rol == "Cliente" ? a.Cliente : a.Admin;
        // El generador omite el claim cuando la cuenta no tiene barbería: así eran los tokens viejos.
        var tokenViejo = api.TokenDe(new Cliente { Id = cuenta.Id, Rol = rol, Correo = cuenta.Correo, BarberiaId = null });
        var http = api.CreateClient();
        http.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", tokenViejo);

        var respuesta = await http.GetAsync(ruta);

        Assert.Equal(HttpStatusCode.Unauthorized, respuesta.StatusCode);
    }

    [Fact]
    public async Task Lo_que_crea_el_admin_queda_en_su_barberia()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);
        var http = api.ComoUsuario(a.Admin);

        var servicio = await DataAsync<ServicioDto>(await http.PostAsJsonAsync("/api/v1/servicios",
            new CreateServicioRequest { Nombre = "Barba", Descripcion = "Perfilado.", Tipo = TipoServicio.Barba, DuracionMinutos = 20, Precio = 20000 },
            Json), HttpStatusCode.Created);

        var guardado = await api.ConBaseAsync(db => db.Servicios.IgnoreQueryFilters().SingleAsync(x => x.Id == servicio.Id));
        Assert.Equal(a.Id, guardado.BarberiaId);
    }

    [Fact]
    public async Task Los_listados_de_citas_y_usuarios_no_muestran_nada_de_otra_barberia()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var http = api.ComoUsuario(a.Admin);

        var citas = await http.GetStringAsync("/api/v1/admin/citas?pageSize=200");
        var usuarios = await http.GetStringAsync("/api/v1/users");

        Assert.Contains(a.Cita.Id.ToString(), citas);
        Assert.DoesNotContain(b.Cita.Id.ToString(), citas);
        Assert.Contains(a.Cliente.Id.ToString(), usuarios);
        Assert.DoesNotContain(b.Cliente.Id.ToString(), usuarios);
    }

    private HttpClient ComoSuperAdmin(Guid? barberiaElegida = null)
    {
        var http = api.ComoUsuario(new Cliente { Rol = "Admin", Correo = "admin@barberia.local", BarberiaId = null });
        if (barberiaElegida is { } id) http.DefaultRequestHeaders.Add("X-Barberia-Id", id.ToString());
        return http;
    }

    [Fact]
    public async Task El_superadmin_sin_barberia_elegida_ve_todas()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);

        var ids = (await DataAsync<List<ClienteDto>>(await ComoSuperAdmin().GetAsync("/api/v1/clientes"))).Select(x => x.Id).ToList();

        Assert.Contains(a.Cliente.Id, ids);
        Assert.Contains(b.Cliente.Id, ids);
    }

    [Fact]
    public async Task El_superadmin_con_una_barberia_elegida_solo_ve_esa()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);

        var ids = (await DataAsync<List<ClienteDto>>(await ComoSuperAdmin(a.Id).GetAsync("/api/v1/clientes"))).Select(x => x.Id).ToList();

        Assert.Contains(a.Cliente.Id, ids);
        Assert.DoesNotContain(b.Cliente.Id, ids);
    }

    private static CreateServicioRequest NuevoServicio => new() { Nombre = "Barba", Descripcion = "Perfilado.", Tipo = TipoServicio.Barba, DuracionMinutos = 20, Precio = 20000 };

    [Fact]
    public async Task El_superadmin_crea_en_la_barberia_elegida()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);

        var servicio = await DataAsync<ServicioDto>(await ComoSuperAdmin(a.Id).PostAsJsonAsync("/api/v1/servicios", NuevoServicio, Json), HttpStatusCode.Created);

        Assert.Equal(a.Id, (await api.ConBaseAsync(db => db.Servicios.IgnoreQueryFilters().SingleAsync(x => x.Id == servicio.Id))).BarberiaId);
    }

    [Fact]
    public async Task El_superadmin_sin_barberia_elegida_no_puede_crear()
    {
        var respuesta = await ComoSuperAdmin().PostAsJsonAsync("/api/v1/servicios", NuevoServicio, Json);

        Assert.Equal(HttpStatusCode.BadRequest, respuesta.StatusCode);
        Assert.Contains("Elige la barbería", await respuesta.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task Elegir_una_barberia_que_no_existe_responde_404()
    {
        var respuesta = await ComoSuperAdmin(Guid.NewGuid()).GetAsync("/api/v1/clientes");

        Assert.Equal(HttpStatusCode.NotFound, respuesta.StatusCode);
    }

    [Fact]
    public async Task El_header_de_barberia_no_le_abre_otra_barberia_a_quien_no_es_superadmin()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var http = api.ComoUsuario(a.Admin);
        http.DefaultRequestHeaders.Add("X-Barberia-Id", b.Id.ToString());

        var ids = (await DataAsync<List<ClienteDto>>(await http.GetAsync("/api/v1/clientes"))).Select(x => x.Id).ToList();

        Assert.Contains(a.Cliente.Id, ids);
        Assert.DoesNotContain(b.Cliente.Id, ids);
    }

    [Fact]
    public async Task Un_cliente_no_puede_apartar_horarios_de_un_barbero_de_otra_barberia()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var http = api.ComoUsuario(a.Cliente);

        var respuesta = await http.PostAsJsonAsync("/api/v1/slots/bloquear", new
        {
            barberoId = b.Barbero.Id,
            servicioId = b.Servicio.Id,
            fechaCita = DateOnly.FromDateTime(DateTime.UtcNow).AddDays(7),
            horaInicio = new TimeOnly(10, 0),
        }, Json);

        Assert.Equal(HttpStatusCode.NotFound, respuesta.StatusCode);
    }
}
