using System.Security.Claims;
using Barberia.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Barberia.Shared;
using Barberia.Shared.Constants;

namespace Barberia.API.Middleware;

public sealed class TenantContextMiddleware
{
    private const string UserIdItemKey = "CurrentUserId";
    private const string ClienteIdItemKey = "CurrentClienteId";
    private const string RoleItemKey = "CurrentUserRole";
    private const string BarberoIdItemKey = "CurrentBarberoId";
    public const string BarberiaElegidaItemKey = "BarberiaElegida";
    public const string BarberiaHeader = "X-Barberia-Id";

    private readonly RequestDelegate next;

    public TenantContextMiddleware(RequestDelegate next)
    {
        this.next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var user = context.User;
        if (user.Identity?.IsAuthenticated != true)
        {
            // Sin sesión, la barbería viaja en la ruta (/barberias/{barberiaId}/...) o en el header.
            var pedida = context.GetRouteValue("barberiaId")?.ToString()
                ?? (context.Request.Headers.TryGetValue(BarberiaHeader, out var h) ? h.ToString() : null);
            if (pedida is not null)
            {
                var db = context.RequestServices.GetRequiredService<BarberiaDbContext>();
                if (!Guid.TryParse(pedida, out var publicaId)
                    || !await db.Barberias.AsNoTracking().AnyAsync(x => x.Id == publicaId && x.Activa, context.RequestAborted))
                {
                    context.Response.StatusCode = StatusCodes.Status404NotFound;
                    await context.Response.WriteAsJsonAsync(ApiResponse<object?>.Fail("La barbería no existe."));
                    return;
                }

                context.Items[BarberiaElegidaItemKey] = publicaId;
            }

            await next(context);
            return;
        }

        var role = user.FindFirstValue(ClaimTypes.Role) ?? string.Empty;
        var userId = ParseGuid(user, "sub", ClaimTypes.NameIdentifier, ClaimTypes.Sid, "clienteId");
        var clienteId = ParseGuid(user, "clienteId", "sub", ClaimTypes.NameIdentifier, ClaimTypes.Sid);
        var barberoId = ParseGuid(user, "barberoId");

        // Todos menos el SuperAdmin pertenecen a una barbería. Un token sin ella es de antes del
        // paso a varias barberías: se pide iniciar sesión de nuevo.
        if (role != Roles.Admin && !Guid.TryParse(user.FindFirstValue("barberiaId"), out _))
        {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            await context.Response.WriteAsJsonAsync(ApiResponse<object?>.Fail("Tu sesión venció. Inicia sesión de nuevo."));
            return;
        }

        if (role == Roles.Barbero && !barberoId.HasValue)
        {
            await WriteForbiddenAsync(context, "El token autenticado no contiene un barbero válido para este rol.");
            return;
        }

        context.Items[RoleItemKey] = role;
        if (userId.HasValue)
            context.Items[UserIdItemKey] = userId.Value;
        if (clienteId.HasValue)
            context.Items[ClienteIdItemKey] = clienteId.Value;
        if (barberoId.HasValue)
            context.Items[BarberoIdItemKey] = barberoId.Value;

        // El SuperAdmin elige con qué barbería trabaja; para los demás manda el token.
        if (role == Roles.Admin && context.Request.Headers.TryGetValue(BarberiaHeader, out var elegida))
        {
            if (!Guid.TryParse(elegida, out var barberiaId))
            {
                context.Response.StatusCode = StatusCodes.Status400BadRequest;
                await context.Response.WriteAsJsonAsync(ApiResponse<object?>.Fail("La barbería elegida no es válida."));
                return;
            }

            var db = context.RequestServices.GetRequiredService<BarberiaDbContext>();
            if (!await db.Barberias.AsNoTracking().AnyAsync(x => x.Id == barberiaId, context.RequestAborted))
            {
                context.Response.StatusCode = StatusCodes.Status404NotFound;
                await context.Response.WriteAsJsonAsync(ApiResponse<object?>.Fail("La barbería no existe."));
                return;
            }

            context.Items[BarberiaElegidaItemKey] = barberiaId;
        }

        await next(context);
    }

    private static Guid? ParseGuid(ClaimsPrincipal user, params string[] claimTypes)
    {
        foreach (var claimType in claimTypes)
        {
            var value = user.FindFirstValue(claimType);
            if (Guid.TryParse(value, out var parsed))
                return parsed;
        }

        return null;
    }

    private static async Task WriteForbiddenAsync(HttpContext context, string message)
    {
        context.Response.StatusCode = StatusCodes.Status403Forbidden;
        await context.Response.WriteAsJsonAsync(ApiResponse<object?>.Fail(message));
    }
}