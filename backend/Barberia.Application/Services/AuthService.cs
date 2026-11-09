using Barberia.Application.Interfaces.Services.Barberias;
using Barberia.Application.DTOs.Auth;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Interfaces.Services.Auth;
using Barberia.Domain.Entities;
using Barberia.Shared.Constants;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Barberia.Application.Services;

public class AuthService : IAuthService
{
    private readonly IBarberiaDbContext dbContext;
    private readonly IJwtTokenGenerator jwtTokenGenerator;
    private readonly ICurrentUserService currentUserService;
    private readonly ICacheService cacheService;
    private readonly ISlotBloqueoService slotBloqueoService;
    private readonly ILogger<AuthService> logger;
    private readonly IBarberiaContexto barberiaContexto;

    public AuthService(
        IBarberiaDbContext dbContext,
        IJwtTokenGenerator jwtTokenGenerator,
        ICurrentUserService currentUserService,
        ICacheService cacheService,
        ISlotBloqueoService slotBloqueoService,
        ILogger<AuthService> logger,
        IBarberiaContexto barberiaContexto)
    {
        this.barberiaContexto = barberiaContexto;
        this.dbContext = dbContext;
        this.jwtTokenGenerator = jwtTokenGenerator;
        this.currentUserService = currentUserService;
        this.cacheService = cacheService;
        this.slotBloqueoService = slotBloqueoService;
        this.logger = logger;
    }

    public async Task<AuthResponseDto> RegistroAsync(RegistroClienteRequest request, CancellationToken cancellationToken)
    {
        var correo = request.Correo.Trim().ToLowerInvariant();
        var barberiaId = await barberiaContexto.ObtenerIdAsync(cancellationToken);
        var existe = await dbContext.Clientes.IgnoreQueryFilters().AnyAsync(x => x.Correo == correo && x.BarberiaId == barberiaId, cancellationToken);
        if (existe)
        {
            throw new ConflictException("Ya existe un cliente registrado con ese correo.");
        }

        var cliente = new Cliente
        {
            BarberiaId = barberiaId,
            Rol = Roles.Cliente,
            Nombre = request.Nombre.Trim(),
            Apellido = request.Apellido.Trim(),
            Telefono = request.Telefono.Trim(),
            Correo = correo,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Activo = true
        };

        await dbContext.Clientes.AddAsync(cliente, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);

        return BuildAuthResponse(cliente);
    }

    public async Task<AuthResponseDto> LoginAsync(LoginRequest request, CancellationToken cancellationToken)
    {
        var correo = request.Correo.Trim().ToLowerInvariant();
        var barberiaId = await barberiaContexto.ObtenerIdAsync(cancellationToken);
        var cliente = await dbContext.Clientes
            .AsNoTracking()
            .IgnoreQueryFilters()
            .Where(x => x.Correo == correo && x.Activo && (x.BarberiaId == barberiaId || x.BarberiaId == null))
            // La cuenta de la barbería va antes que la del SuperAdmin con el mismo correo.
            .OrderBy(x => x.BarberiaId == null)
            .FirstOrDefaultAsync(cancellationToken);

        if (cliente is null || !BCrypt.Net.BCrypt.Verify(request.Password, cliente.PasswordHash))
        {
            throw new UnauthorizedException("Correo o contraseña inválidos.");
        }

        return BuildAuthResponse(cliente);
    }

    public async Task UpdateClienteFcmTokenAsync(string token, CancellationToken cancellationToken)
    {
        if (!currentUserService.IsCliente || currentUserService.ClienteId is null)
        {
            throw new UnauthorizedException("Debes iniciar sesión como cliente.");
        }

        var cliente = await dbContext.Clientes
            .FirstOrDefaultAsync(x => x.Id == currentUserService.ClienteId.Value && x.Activo, cancellationToken);

        if (cliente is null)
        {
            throw new NotFoundException("El cliente autenticado no existe.");
        }

        cliente.TokenFCM = string.IsNullOrWhiteSpace(token) ? null : token.Trim();
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task LogoutAsync(CancellationToken cancellationToken)
    {
        if (!currentUserService.IsCliente || currentUserService.ClienteId is null)
        {
            return;
        }

        var clienteId = currentUserService.ClienteId.Value;
        logger.LogInformation("Cerrando sesión para cliente {ClienteId}", clienteId);

        var lockSetKey = $"appointment:cliente:{clienteId}:locks";
        var pendingLockKeys = await cacheService.PopSetAsync(lockSetKey, cancellationToken);

        foreach (var lockKey in pendingLockKeys)
        {
            await cacheService.DeleteAsync(lockKey, cancellationToken);
            logger.LogDebug("Lock eliminado en logout: {LockKey}", lockKey);
        }

        var legacyLocksRemoved = await slotBloqueoService.LiberarTodosDelClienteAsync(clienteId, cancellationToken);
        if (legacyLocksRemoved > 0)
        {
            logger.LogInformation(
                "Se eliminaron {Count} locks legacy de slots para cliente {ClienteId} al cerrar sesión",
                legacyLocksRemoved,
                clienteId);
        }

        if (pendingLockKeys.Count > 0 || legacyLocksRemoved > 0)
        {
            logger.LogInformation(
                "Se eliminaron {Count} bloqueos de Redis para cliente {ClienteId} al cerrar sesión",
                pendingLockKeys.Count + legacyLocksRemoved,
                clienteId);
        }
    }

    private AuthResponseDto BuildAuthResponse(Cliente cliente)
    {
        return new AuthResponseDto
        {
            Token = jwtTokenGenerator.GenerateClienteToken(cliente),
            ClienteId = cliente.Id,
            Correo = cliente.Correo,
            Rol = string.IsNullOrWhiteSpace(cliente.Rol) ? Roles.Cliente : cliente.Rol,
            NombreCompleto = $"{cliente.Nombre} {cliente.Apellido}".Trim(),
            BarberoId = cliente.BarberoId
        };
    }
}
