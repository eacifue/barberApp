using System.Security.Claims;
using Barberia.Application.Interfaces.Services;
using Barberia.Shared.Constants;

namespace Barberia.API.Services;

public class CurrentUserService : ICurrentUserService
{
    private const string UserIdItemKey = "CurrentUserId";
    private const string ClienteIdItemKey = "CurrentClienteId";
    private const string RoleItemKey = "CurrentUserRole";
    private const string BarberoIdItemKey = "CurrentBarberoId";

    private readonly IHttpContextAccessor httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        this.httpContextAccessor = httpContextAccessor;
    }

    public Guid? UserId
    {
        get
        {
            var contextualId = GetItemGuid(UserIdItemKey);
            if (contextualId.HasValue)
                return contextualId;

            var value = httpContextAccessor.HttpContext?.User.FindFirstValue("sub")
                ?? httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.Sid)
                ?? httpContextAccessor.HttpContext?.User.FindFirstValue("clienteId");

            return Guid.TryParse(value, out var userId) ? userId : null;
        }
    }

    public Guid? ClienteId
    {
        get
        {
            var contextualId = GetItemGuid(ClienteIdItemKey);
            if (contextualId.HasValue)
                return contextualId;

            var value = httpContextAccessor.HttpContext?.User.FindFirstValue("clienteId");
            return Guid.TryParse(value, out var clienteId) ? clienteId : UserId;
        }
    }

    public string Role => httpContextAccessor.HttpContext?.Items[RoleItemKey] as string
        ?? httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.Role)
        ?? string.Empty;

    public bool IsAuthenticated => httpContextAccessor.HttpContext?.User.Identity?.IsAuthenticated == true;

    public bool IsAdmin => string.Equals(Role, Roles.Admin, StringComparison.Ordinal);

    public bool IsAdminBarberia => string.Equals(Role, Roles.AdminBarberia, StringComparison.Ordinal);

    public bool IsBarbero => string.Equals(Role, Roles.Barbero, StringComparison.Ordinal);

    public bool IsCliente => string.Equals(Role, Roles.Cliente, StringComparison.Ordinal);

    public Guid? BarberoId
    {
        get
        {
            var contextualId = GetItemGuid(BarberoIdItemKey);
            if (contextualId.HasValue)
                return contextualId;

            var value = httpContextAccessor.HttpContext?.User.FindFirstValue("barberoId");
            return Guid.TryParse(value, out var id) ? id : null;
        }
    }

    public Guid? BarberiaId
    {
        get
        {
            var value = httpContextAccessor.HttpContext?.User.FindFirstValue("barberiaId");
            if (Guid.TryParse(value, out var id))
                return id;

            return GetItemGuid(Middleware.TenantContextMiddleware.BarberiaElegidaItemKey);
        }
    }

    public bool VeTodasLasBarberias =>
        httpContextAccessor.HttpContext is null
        || (IsAdmin && BarberiaId is null);

    private Guid? GetItemGuid(string key)
    {
        return httpContextAccessor.HttpContext?.Items.TryGetValue(key, out var value) == true && value is Guid parsed
            ? parsed
            : null;
    }
}
