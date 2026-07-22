using Barberia.Application.DTOs.Users;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services;
using Barberia.Domain.Entities;
using Barberia.Shared;
using Barberia.Shared.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Barberia.API.Controllers;

[ApiController]
[Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
public class UsersController : ControllerBase
{
    private readonly IBarberiaDbContext dbContext;
    private readonly ICurrentUserService currentUserService;

    public UsersController(IBarberiaDbContext dbContext, ICurrentUserService currentUserService)
    {
        this.dbContext = dbContext;
        this.currentUserService = currentUserService;
    }

    [HttpGet("api/v1/users")]
    public async Task<ActionResult<ApiResponse<List<UserDto>>>> GetAllAsync(CancellationToken cancellationToken)
    {
        var users = await dbContext.Clientes
            .AsNoTracking()
            .OrderBy(x => x.Nombre)
            .Select(x => new UserDto(
                x.Id,
                x.Nombre,
                x.Apellido,
                x.Correo,
                x.Telefono,
                x.Rol,
                x.BarberiaId,
                x.BarberoId,
                x.Activo,
                x.CreatedAt))
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<UserDto>>.Ok(users));
    }

    [HttpGet("api/v1/users/{id:guid}")]
    public async Task<ActionResult<ApiResponse<UserDto>>> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var user = await dbContext.Clientes
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new UserDto(
                x.Id,
                x.Nombre,
                x.Apellido,
                x.Correo,
                x.Telefono,
                x.Rol,
                x.BarberiaId,
                x.BarberoId,
                x.Activo,
                x.CreatedAt))
            .FirstOrDefaultAsync(cancellationToken);

        if (user is null)
            return NotFound(ApiResponse<UserDto>.Fail("Usuario no encontrado."));

        return Ok(ApiResponse<UserDto>.Ok(user));
    }

    [HttpPost("api/v1/users")]
    public async Task<ActionResult<ApiResponse<UserDto>>> CreateAsync(
        [FromBody] CreateUserRequest request,
        CancellationToken cancellationToken)
    {
        var role = ValidateRole(request.Rol);

        if (currentUserService.IsAdminBarberia && role is not (Roles.Barbero or Roles.Cliente))
            return Forbid();

        var assignedBarberiaId = ResolveTargetBarberiaId(role, request.BarberiaId);
        var assignedBarberoId = await ResolveTargetBarberoIdAsync(role, assignedBarberiaId, request.BarberoId, cancellationToken);

        var validationError = await ValidateRoleAssignmentAsync(role, assignedBarberiaId, assignedBarberoId, cancellationToken);
        if (validationError is not null)
            return validationError;

        // Solo 1 Admin global
        if (role == Roles.Admin)
        {
            var adminExists = await dbContext.Clientes
                .IgnoreQueryFilters()
                .AnyAsync(x => x.Rol == Roles.Admin && x.Activo, cancellationToken);

            if (adminExists)
                return Conflict(ApiResponse<UserDto>.Fail("Ya existe un usuario con rol Admin."));
        }

        var correo = request.Correo.Trim().ToLowerInvariant();
        var emailExists = await dbContext.Clientes
            .IgnoreQueryFilters()
            .AnyAsync(x => x.Correo == correo, cancellationToken);
        if (emailExists)
            return Conflict(ApiResponse<UserDto>.Fail("Ya existe un usuario con ese correo."));

        var cliente = new Cliente
        {
            Nombre = request.Nombre.Trim(),
            Apellido = request.Apellido.Trim(),
            Correo = correo,
            Telefono = request.Telefono.Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Rol = role,
            BarberiaId = assignedBarberiaId,
            BarberoId = assignedBarberoId,
            Activo = true
        };

        await dbContext.Clientes.AddAsync(cliente, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);

        var dto = ToDto(cliente);
        return Created($"/api/v1/users/{cliente.Id}", ApiResponse<UserDto>.Ok(dto, "Usuario creado."));
    }

    [HttpPut("api/v1/users/{id:guid}")]
    public async Task<ActionResult<ApiResponse<UserDto>>> UpdateAsync(
        Guid id,
        [FromBody] UpdateUserRequest request,
        CancellationToken cancellationToken)
    {
        var cliente = await dbContext.Clientes.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (cliente is null)
            return NotFound(ApiResponse<UserDto>.Fail("Usuario no encontrado."));

        if (currentUserService.IsAdminBarberia && cliente.Rol == Roles.Admin)
            return Forbid();

        var newRole = string.IsNullOrWhiteSpace(request.Rol) ? cliente.Rol : ValidateRole(request.Rol);
        if (currentUserService.IsAdminBarberia && newRole is not (Roles.Barbero or Roles.Cliente))
            return Forbid();

        if (!string.IsNullOrWhiteSpace(request.Rol))
        {
            // Solo 1 Admin global
            if (newRole == Roles.Admin && cliente.Rol != Roles.Admin)
            {
                var adminExists = await dbContext.Clientes
                    .IgnoreQueryFilters()
                    .AnyAsync(x => x.Rol == Roles.Admin && x.Activo && x.Id != id, cancellationToken);

                if (adminExists)
                    return Conflict(ApiResponse<UserDto>.Fail("Ya existe un usuario con rol Admin."));
            }

            cliente.Rol = newRole;
        }

        var assignedBarberiaId = ResolveTargetBarberiaId(newRole, request.BarberiaId ?? cliente.BarberiaId);
        var assignedBarberoId = await ResolveTargetBarberoIdAsync(newRole, assignedBarberiaId, request.BarberoId ?? cliente.BarberoId, cancellationToken);

        var validationError = await ValidateRoleAssignmentAsync(newRole, assignedBarberiaId, assignedBarberoId, cancellationToken);
        if (validationError is not null)
            return validationError;

        if (!string.IsNullOrWhiteSpace(request.Nombre)) cliente.Nombre = request.Nombre.Trim();
        if (!string.IsNullOrWhiteSpace(request.Apellido)) cliente.Apellido = request.Apellido.Trim();
        if (!string.IsNullOrWhiteSpace(request.Telefono)) cliente.Telefono = request.Telefono.Trim();
        if (request.Activo.HasValue) cliente.Activo = request.Activo.Value;

        cliente.BarberiaId = assignedBarberiaId;
        cliente.BarberoId = assignedBarberoId;
        cliente.Rol = newRole;

        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<UserDto>.Ok(ToDto(cliente), "Usuario actualizado."));
    }

    [HttpDelete("api/v1/users/{id:guid}")]
    public async Task<ActionResult<ApiResponse<object?>>> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var cliente = await dbContext.Clientes.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (cliente is null)
            return NotFound(ApiResponse<object?>.Fail("Usuario no encontrado."));

        if (cliente.Rol == Roles.Admin)
            return BadRequest(ApiResponse<object?>.Fail("No se puede eliminar el usuario Admin."));

        // Soft delete
        cliente.Activo = false;
        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, "Usuario desactivado."));
    }

    private static string ValidateRole(string rol)
    {
        return rol switch
        {
            Roles.Admin => Roles.Admin,
            Roles.AdminBarberia => Roles.AdminBarberia,
            Roles.Barbero => Roles.Barbero,
            Roles.Cliente => Roles.Cliente,
            _ => throw new ValidationException($"Rol inválido: {rol}. Valores permitidos: Admin, AdministradorBarberia, Barbero, Cliente.")
        };
    }

    private static UserDto ToDto(Cliente c) =>
        new(c.Id, c.Nombre, c.Apellido, c.Correo, c.Telefono, c.Rol, c.BarberiaId, c.BarberoId, c.Activo, c.CreatedAt);

    private Guid? ResolveTargetBarberiaId(string role, Guid? requestedBarberiaId)
    {
        if (role == Roles.Admin)
            return null;

        if (currentUserService.IsAdminBarberia)
            return currentUserService.BarberiaId;

        return requestedBarberiaId;
    }

    private async Task<Guid?> ResolveTargetBarberoIdAsync(string role, Guid? barberiaId, Guid? requestedBarberoId, CancellationToken cancellationToken)
    {
        if (role != Roles.Barbero)
            return null;

        if (!requestedBarberoId.HasValue)
            return null;

        var exists = await dbContext.Barberos
            .IgnoreQueryFilters()
            .AnyAsync(x => x.Id == requestedBarberoId.Value && x.Activo && (!barberiaId.HasValue || x.BarberiaId == barberiaId.Value), cancellationToken);

        if (!exists)
            throw new ValidationException("El barbero indicado no existe o no pertenece a la barbería seleccionada.");

        return requestedBarberoId;
    }

    private async Task<ActionResult<ApiResponse<UserDto>>?> ValidateRoleAssignmentAsync(
        string role,
        Guid? barberiaId,
        Guid? barberoId,
        CancellationToken cancellationToken)
    {
        if (role == Roles.Admin)
        {
            if (barberiaId.HasValue)
                return BadRequest(ApiResponse<UserDto>.Fail("El usuario Admin no puede estar asociado a una barbería."));

            return null;
        }

        if (role is Roles.AdminBarberia or Roles.Barbero)
        {
            if (!barberiaId.HasValue)
                return BadRequest(ApiResponse<UserDto>.Fail($"La barbería es obligatoria para el rol {role}."));
        }

        if (barberiaId.HasValue)
        {
            var barberiaExists = await dbContext.Barberias
                .IgnoreQueryFilters()
                .AnyAsync(x => x.Id == barberiaId.Value && x.Activa && x.Activo, cancellationToken);

            if (!barberiaExists)
                return BadRequest(ApiResponse<UserDto>.Fail("La barbería indicada no existe o está inactiva."));
        }

        if (role == Roles.Barbero && !barberoId.HasValue)
            return BadRequest(ApiResponse<UserDto>.Fail("El rol Barbero requiere un BarberoId asociado."));

        return null;
    }
}
