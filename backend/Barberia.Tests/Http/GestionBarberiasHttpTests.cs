using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Barberia.Application.DTOs.Auth;
using Barberia.Application.DTOs.Barberias;
using Barberia.Domain.Entities;
using Barberia.Shared;
using Barberia.Shared.Constants;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Tests.Http;

// El SuperAdmin da de alta barberías (con su primer administrador), las desactiva y
// las reactiva. Una barbería desactivada deja fuera a su gente.
public sealed class GestionBarberiasHttpTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    private HttpClient SuperAdmin() => api.ComoUsuario(new Cliente { Rol = Roles.Admin, Correo = "admin@barberia.local", BarberiaId = null });

    private static object NuevaBarberia(string correoAdmin) => new
    {
        nombre = "Barbería Laureles",
        telefono = "3011419610",
        correo = "laureles@correo.co",
        direccion = "Cra 76 #33",
        ciudad = "Medellín",
        departamento = "Antioquia",
        pais = "Colombia",
        horaApertura = "09:00",
        horaCierre = "19:00",
        administrador = new { nombre = "Sara", apellido = "Gómez", telefono = "3001234567", correo = correoAdmin, password = "secreta1" },
    };

    private static async Task<T> DataAsync<T>(HttpResponseMessage respuesta, HttpStatusCode esperado)
    {
        Assert.True(respuesta.StatusCode == esperado, $"{(int)respuesta.StatusCode}: {await respuesta.Content.ReadAsStringAsync()}");
        return (await respuesta.Content.ReadFromJsonAsync<ApiResponse<T>>(Json))!.Data!;
    }

    [Fact]
    public async Task El_superadmin_crea_una_barberia_con_su_administrador_y_el_administrador_puede_entrar()
    {
        var correoAdmin = $"{Guid.NewGuid():N}@correo.co";

        var barberia = await DataAsync<BarberiaDto>(await SuperAdmin().PostAsJsonAsync("/api/v1/admin/barberias", NuevaBarberia(correoAdmin), Json), HttpStatusCode.Created);

        var login = await api.CreateClient().PostAsJsonAsync("/api/v1/auth/login", new { correo = correoAdmin, password = "secreta1" }, Json);
        var sesion = await DataAsync<AuthResponseDto>(login, HttpStatusCode.OK);
        Assert.Equal(Roles.AdminBarberia, sesion.Rol);
        var cuenta = await api.ConBaseAsync(db => db.Clientes.IgnoreQueryFilters().SingleAsync(x => x.Id == sesion.ClienteId));
        Assert.Equal(barberia.Id, cuenta.BarberiaId);
    }

    [Fact]
    public async Task Con_un_administrador_invalido_no_se_crea_nada()
    {
        var antes = await api.ConBaseAsync(db => db.Barberias.CountAsync());

        var respuesta = await SuperAdmin().PostAsJsonAsync("/api/v1/admin/barberias", NuevaBarberia("sin-arroba"), Json);

        Assert.Equal(HttpStatusCode.BadRequest, respuesta.StatusCode);
        Assert.Contains("correo válido", await respuesta.Content.ReadAsStringAsync());
        Assert.Equal(antes, await api.ConBaseAsync(db => db.Barberias.CountAsync()));
    }

    [Fact]
    public async Task Un_administrador_de_barberia_no_puede_crear_barberias()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);

        var respuesta = await api.ComoUsuario(a.Admin).PostAsJsonAsync("/api/v1/admin/barberias", NuevaBarberia($"{Guid.NewGuid():N}@correo.co"), Json);

        Assert.Equal(HttpStatusCode.Forbidden, respuesta.StatusCode);
    }

    private Task<bool> ActivaAsync(Guid id) => api.ConBaseAsync(async db => (await db.Barberias.SingleAsync(x => x.Id == id)).Activa);

    [Fact]
    public async Task El_superadmin_desactiva_y_reactiva_una_barberia()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);
        var http = SuperAdmin();

        var desactivar = await http.PutAsync($"/api/v1/admin/barberias/{a.Id}/desactivar", null);
        var activaTrasDesactivar = await ActivaAsync(a.Id);
        var activar = await http.PutAsync($"/api/v1/admin/barberias/{a.Id}/activar", null);

        Assert.Equal(HttpStatusCode.OK, desactivar.StatusCode);
        Assert.False(activaTrasDesactivar);
        Assert.Equal(HttpStatusCode.OK, activar.StatusCode);
        Assert.True(await ActivaAsync(a.Id));
    }

    [Fact]
    public async Task Desactivar_una_barberia_que_no_existe_responde_404()
    {
        var respuesta = await SuperAdmin().PutAsync($"/api/v1/admin/barberias/{Guid.NewGuid()}/desactivar", null);

        Assert.Equal(HttpStatusCode.NotFound, respuesta.StatusCode);
        Assert.Contains("La barbería no existe", await respuesta.Content.ReadAsStringAsync());
    }

    private async Task DesactivarAsync(Guid id) =>
        Assert.Equal(HttpStatusCode.OK, (await SuperAdmin().PutAsync($"/api/v1/admin/barberias/{id}/desactivar", null)).StatusCode);

    [Fact]
    public async Task En_una_barberia_desactivada_su_gente_no_puede_iniciar_sesion()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);
        await DesactivarAsync(a.Id);

        var respuesta = await api.CreateClient().PostAsJsonAsync("/api/v1/auth/login", new { correo = a.Admin.Correo, password = "secreta1" }, Json);

        Assert.Equal(HttpStatusCode.Unauthorized, respuesta.StatusCode);
        Assert.Contains("Tu barbería está desactivada", await respuesta.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task En_una_barberia_desactivada_las_sesiones_abiertas_dejan_de_servir()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);
        var cliente = api.ComoUsuario(a.Cliente);
        await DesactivarAsync(a.Id);

        var respuesta = await cliente.GetAsync("/api/v1/citas/mis-citas");

        Assert.Equal(HttpStatusCode.Unauthorized, respuesta.StatusCode);
        Assert.Contains("Tu barbería está desactivada", await respuesta.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task El_superadmin_sigue_operando_una_barberia_desactivada()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);
        await DesactivarAsync(a.Id);
        var http = SuperAdmin();
        http.DefaultRequestHeaders.Add("X-Barberia-Id", a.Id.ToString());

        var respuesta = await http.GetAsync("/api/v1/clientes");

        Assert.Equal(HttpStatusCode.OK, respuesta.StatusCode);
        Assert.Contains(a.Cliente.Id.ToString(), await respuesta.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task El_listado_publico_para_elegir_barberia_solo_trae_las_activas()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        await DesactivarAsync(a.Id);

        var cuerpo = await api.CreateClient().GetStringAsync("/api/v1/barberias");

        Assert.Contains(b.Id.ToString(), cuerpo);
        Assert.DoesNotContain(a.Id.ToString(), cuerpo);
    }

    [Fact]
    public async Task El_resumen_por_barberia_sale_de_Postgres_y_es_solo_para_el_superadmin()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);
        // La cita sembrada es del 1 dic 2026; se pasa a hoy (Colombia) y completada para que cuente.
        var hoy = DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(DateTimeOffset.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("America/Bogota")).DateTime);
        await api.ConBaseAsync(db => db.Citas.IgnoreQueryFilters().Where(x => x.Id == a.Cita.Id)
            .ExecuteUpdateAsync(s => s.SetProperty(x => x.FechaCita, hoy).SetProperty(x => x.Estado, Barberia.Domain.Enums.EstadoCita.Completada)));

        var resumen = await DataAsync<List<ResumenBarberiaDto>>(await SuperAdmin().GetAsync("/api/v1/admin/barberias/resumen"), HttpStatusCode.OK);
        var deAdminDeBarberia = await api.ComoUsuario(a.Admin).GetAsync("/api/v1/admin/barberias/resumen");

        var deA = Assert.Single(resumen, x => x.BarberiaId == a.Id);
        Assert.Equal(1, deA.CitasMes);
        Assert.Equal(35000m, deA.IngresosMes);
        Assert.Equal(1, deA.Clientes);
        Assert.Equal(1, deA.BarberosActivos);
        Assert.Equal(HttpStatusCode.Forbidden, deAdminDeBarberia.StatusCode);
    }

    // «Mi negocio»: el administrador de una barbería edita los datos de la suya, y solo de la suya.
    private static object DatosNegocio(string nombre) => new
    {
        nombre,
        telefono = "3011419610",
        correo = "negocio@correo.co",
        direccion = "Cra 76 #33",
        ciudad = "Medellín",
        departamento = "Antioquia",
        pais = "Colombia",
        horaApertura = "09:00",
        horaCierre = "19:00",
    };

    private Task<string> NombreAsync(Guid id) => api.ConBaseAsync(async db => (await db.Barberias.SingleAsync(x => x.Id == id)).Nombre);

    [Fact]
    public async Task El_administrador_de_barberia_edita_los_datos_de_su_barberia()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);

        var respuesta = await api.ComoUsuario(a.Admin).PutAsJsonAsync($"/api/v1/admin/barberias/{a.Id}", DatosNegocio("Barbería A renovada"), Json);

        Assert.True(respuesta.StatusCode == HttpStatusCode.OK, $"{(int)respuesta.StatusCode}: {await respuesta.Content.ReadAsStringAsync()}");
        Assert.Equal("Barbería A renovada", await NombreAsync(a.Id));
    }

    [Fact]
    public async Task El_administrador_de_barberia_no_puede_editar_otra_barberia()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var nombreDeB = await NombreAsync(b.Id);

        var respuesta = await api.ComoUsuario(a.Admin).PutAsJsonAsync($"/api/v1/admin/barberias/{b.Id}", DatosNegocio("Tomada por A"), Json);

        Assert.Equal(HttpStatusCode.NotFound, respuesta.StatusCode);
        Assert.Equal(nombreDeB, await NombreAsync(b.Id));
    }

    [Fact]
    public async Task El_administrador_de_barberia_solo_ve_su_barberia_en_el_listado_de_administracion()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);

        var lista = await DataAsync<List<BarberiaDto>>(await api.ComoUsuario(a.Admin).GetAsync("/api/v1/admin/barberias"), HttpStatusCode.OK);

        Assert.Equal([a.Id], lista.Select(x => x.Id));
    }

    [Fact]
    public async Task El_administrador_de_barberia_no_puede_ver_otra_barberia_por_id()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var http = api.ComoUsuario(a.Admin);

        var suya = await http.GetAsync($"/api/v1/admin/barberias/{a.Id}");
        var ajena = await http.GetAsync($"/api/v1/admin/barberias/{b.Id}");

        Assert.Equal(HttpStatusCode.OK, suya.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, ajena.StatusCode);
    }

    [Fact]
    public async Task El_administrador_de_barberia_no_puede_desactivar_ni_activar_barberias()
    {
        var (a, _) = await DosBarberias.CrearAsync(api);
        var http = api.ComoUsuario(a.Admin);

        var desactivar = await http.PutAsync($"/api/v1/admin/barberias/{a.Id}/desactivar", null);
        var activar = await http.PutAsync($"/api/v1/admin/barberias/{a.Id}/activar", null);

        Assert.Equal(HttpStatusCode.Forbidden, desactivar.StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, activar.StatusCode);
        Assert.True(await ActivaAsync(a.Id));
    }

    [Fact]
    public async Task El_superadmin_ve_y_edita_cualquier_barberia()
    {
        var (a, b) = await DosBarberias.CrearAsync(api);
        var http = SuperAdmin();

        var lista = await DataAsync<List<BarberiaDto>>(await http.GetAsync("/api/v1/admin/barberias"), HttpStatusCode.OK);
        var editar = await http.PutAsJsonAsync($"/api/v1/admin/barberias/{b.Id}", DatosNegocio("B editada por el SuperAdmin"), Json);

        Assert.Contains(lista, x => x.Id == a.Id);
        Assert.Contains(lista, x => x.Id == b.Id);
        Assert.Equal(HttpStatusCode.OK, editar.StatusCode);
        Assert.Equal("B editada por el SuperAdmin", await NombreAsync(b.Id));
    }

    [Fact]
    public async Task Al_guardar_mi_negocio_el_administrador_de_barberia_no_puede_desactivarla()
    {
        // Activar y desactivar es del SuperAdmin; desde «Mi negocio» el campo se ignora.
        var (a, _) = await DosBarberias.CrearAsync(api);
        var datos = new Dictionary<string, object?>
        {
            ["nombre"] = "Barbería A", ["telefono"] = "3011419610", ["correo"] = "negocio@correo.co", ["direccion"] = "Cra 76 #33",
            ["ciudad"] = "Medellín", ["departamento"] = "Antioquia", ["pais"] = "Colombia", ["horaApertura"] = "09:00", ["horaCierre"] = "19:00",
            ["activa"] = false,
        };

        var respuesta = await api.ComoUsuario(a.Admin).PutAsJsonAsync($"/api/v1/admin/barberias/{a.Id}", datos, Json);

        Assert.Equal(HttpStatusCode.OK, respuesta.StatusCode);
        Assert.True(await ActivaAsync(a.Id));
    }
}
