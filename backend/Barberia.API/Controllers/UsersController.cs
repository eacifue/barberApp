using Barberia.Application.Interfaces.Services.Barberias;
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
    private readonly IBarberiaContexto barberiaContexto;

    public UsersController(IBarberiaDbContext dbContext, ICurrentUserService currentUserService, IBarberiaContexto barberiaContexto)
    {
        this.barberiaContexto = barberiaContexto;
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

        // El SuperAdmin no pertenece a ninguna barbería; los demás, a la del contexto.
        Guid? barberiaId = role == Roles.Admin ? null : await barberiaContexto.ObtenerIdAsync(cancellationToken);
        var assignedBarberoId = await ResolveTargetBarberoIdAsync(role, request.BarberoId, barberiaId, cancellationToken);

        var validationError = ValidateRoleAssignment(role, assignedBarberoId);
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
            .AnyAsync(x => x.Correo == correo && x.BarberiaId == barberiaId, cancellationToken);
        if (emailExists)
            return Conflict(ApiResponse<UserDto>.Fail("Ya existe un usuario con ese correo."));

        var cliente = new Cliente
        {
            BarberiaId = barberiaId,
            Nombre = request.Nombre.Trim(),
            Apellido = request.Apellido.Trim(),
            Correo = correo,
            Telefono = request.Telefono.Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Rol = role,
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

        Guid? barberiaId = newRole == Roles.Admin ? null : cliente.BarberiaId ?? await barberiaContexto.ObtenerIdAsync(cancellationToken);
        var assignedBarberoId = await ResolveTargetBarberoIdAsync(newRole, request.BarberoId ?? cliente.BarberoId, barberiaId, cancellationToken);

        var validationError = ValidateRoleAssignment(newRole, assignedBarberoId);
        if (validationError is not null)
            return validationError;

        if (!string.IsNullOrWhiteSpace(request.Nombre)) cliente.Nombre = request.Nombre.Trim();
        if (!string.IsNullOrWhiteSpace(request.Apellido)) cliente.Apellido = request.Apellido.Trim();
        if (!string.IsNullOrWhiteSpace(request.Telefono)) cliente.Telefono = request.Telefono.Trim();
        if (request.Activo.HasValue) cliente.Activo = request.Activo.Value;

        cliente.BarberoId = assignedBarberoId;
        cliente.Rol = newRole;
        cliente.BarberiaId = barberiaId;

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
        new(c.Id, c.Nombre, c.Apellido, c.Correo, c.Telefono, c.Rol, c.BarberoId, c.Activo, c.CreatedAt);

    private async Task<Guid?> ResolveTargetBarberoIdAsync(string role, Guid? requestedBarberoId, Guid? barberiaId, CancellationToken cancellationToken)
    {
        if (role != Roles.Barbero)
            return null;

        if (!requestedBarberoId.HasValue)
            return null;

        var exists = await dbContext.Barberos
            .IgnoreQueryFilters()
            .AnyAsync(x => x.Id == requestedBarberoId.Value && x.Activo && x.BarberiaId == barberiaId, cancellationToken);

        if (!exists)
            throw new ValidationException("El barbero indicado no existe en esta barbería.");

        return requestedBarberoId;
    }

    private ActionResult<ApiResponse<UserDto>>? ValidateRoleAssignment(string role, Guid? barberoId)
    {
        if (role == Roles.Barbero && !barberoId.HasValue)
            return BadRequest(ApiResponse<UserDto>.Fail("El rol Barbero requiere un BarberoId asociado."));

        return null;
    }
}
