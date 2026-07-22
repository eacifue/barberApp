using System.Security.Claims;
using Barberia.Shared;
using Barberia.Shared.Constants;

namespace Barberia.API.Middleware;

public sealed class TenantContextMiddleware
{
    private const string UserIdItemKey = "CurrentUserId";
    private const string ClienteIdItemKey = "CurrentClienteId";
    private const string RoleItemKey = "CurrentUserRole";
    private const string BarberiaIdItemKey = "CurrentBarberiaId";
    private const string BarberoIdItemKey = "CurrentBarberoId";

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
            await next(context);
            return;
        }

        var role = user.FindFirstValue(ClaimTypes.Role) ?? string.Empty;
        var userId = ParseGuid(user, "sub", ClaimTypes.NameIdentifier, ClaimTypes.Sid, "clienteId");
        var clienteId = ParseGuid(user, "clienteId", "sub", ClaimTypes.NameIdentifier, ClaimTypes.Sid);
        var barberiaId = ParseGuid(user, "barberiaId");
        var barberoId = ParseGuid(user, "barberoId");

        if ((role == Roles.AdminBarberia || role == Roles.Barbero) && !barberiaId.HasValue)
        {
            await WriteForbiddenAsync(context, "El token autenticado no contiene una barbería válida para este rol.");
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
        if (barberiaId.HasValue)
            context.Items[BarberiaIdItemKey] = barberiaId.Value;
        if (barberoId.HasValue)
            context.Items[BarberoIdItemKey] = barberoId.Value;

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