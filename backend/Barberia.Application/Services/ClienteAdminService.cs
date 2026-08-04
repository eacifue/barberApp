using AutoMapper;
using Barberia.Application.DTOs.Clientes;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Interfaces.Services.Clientes;
using Barberia.Domain.Entities;
using Barberia.Shared.Constants;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using AppValidationException = Barberia.Application.Exceptions.ValidationException;

namespace Barberia.Application.Services;

public sealed class ClienteAdminService : IClienteAdminService
{
    private readonly IBarberiaDbContext dbContext;
    private readonly IMapper mapper;
    private readonly IValidator<CreateClienteAdminRequest> createValidator;
    private readonly IValidator<UpdateClienteAdminRequest> updateValidator;

    public ClienteAdminService(
        IBarberiaDbContext dbContext,
        IMapper mapper,
        IValidator<CreateClienteAdminRequest> createValidator,
        IValidator<UpdateClienteAdminRequest> updateValidator)
    {
        this.dbContext = dbContext;
        this.mapper = mapper;
        this.createValidator = createValidator;
        this.updateValidator = updateValidator;
    }

    public async Task<List<ClienteDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var clientes = await dbContext.Clientes
            .AsNoTracking()
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);

        var barberiaIds = clientes
            .Where(x => x.BarberiaId.HasValue)
            .Select(x => x.BarberiaId!.Value)
            .Distinct()
            .ToList();

        var barberiasById = barberiaIds.Count == 0
            ? new Dictionary<Guid, string>()
            : await dbContext.Barberias
                .AsNoTracking()
                .Where(x => barberiaIds.Contains(x.Id))
                .Select(x => new { x.Id, x.Nombre })
                .ToDictionaryAsync(x => x.Id, x => x.Nombre, cancellationToken);

        var dtos = mapper.Map<List<ClienteDto>>(clientes);
        foreach (var dto in dtos)
        {
            dto.BarberiaNombre = dto.BarberiaId.HasValue && barberiasById.TryGetValue(dto.BarberiaId.Value, out var nombre)
                ? nombre
                : null;
        }

        return dtos;
    }

    public async Task<ClienteDto> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var cliente = await dbContext.Clientes
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (cliente is null)
        {
            throw new NotFoundException("El cliente no existe.");
        }

        var dto = mapper.Map<ClienteDto>(cliente);
        if (cliente.BarberiaId.HasValue)
        {
            dto.BarberiaNombre = await dbContext.Barberias
                .AsNoTracking()
                .Where(x => x.Id == cliente.BarberiaId.Value)
                .Select(x => x.Nombre)
                .FirstOrDefaultAsync(cancellationToken);
        }

        return dto;
    }

    public async Task<ClienteDto> CreateAsync(CreateClienteAdminRequest request, CancellationToken cancellationToken)
    {
        await ValidateAsync(request, cancellationToken);

        var barberiaId = request.BarberiaId;

        if (barberiaId.HasValue)
        {
            await EnsureBarberiaExistsAsync(barberiaId.Value, cancellationToken);
        }

        var correo = request.Correo.Trim().ToLowerInvariant();
        var existe = await dbContext.Clientes.AnyAsync(x => x.Correo == correo, cancellationToken);
        if (existe)
        {
            throw new ConflictException("Ya existe un cliente con ese correo.");
        }

        var cliente = new Cliente
        {
            Rol = Roles.Cliente,
            BarberiaId = barberiaId,
            Nombre = request.Nombre.Trim(),
            Apellido = request.Apellido.Trim(),
            Telefono = request.Telefono.Trim(),
            Correo = correo,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Activo = true
        };

        await dbContext.Clientes.AddAsync(cliente, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);

        return mapper.Map<ClienteDto>(cliente);
    }

    public async Task<ClienteDto> UpdateAsync(Guid id, UpdateClienteAdminRequest request, CancellationToken cancellationToken)
    {
        await ValidateAsync(request, cancellationToken);

        var barberiaId = request.BarberiaId;

        if (barberiaId.HasValue)
        {
            await EnsureBarberiaExistsAsync(barberiaId.Value, cancellationToken);
        }

        var cliente = await dbContext.Clientes
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (cliente is null)
        {
            throw new NotFoundException("El cliente no existe.");
        }

        var correo = request.Correo.Trim().ToLowerInvariant();
        var correoOcupado = await dbContext.Clientes
            .AnyAsync(x => x.Id != id && x.Correo == correo, cancellationToken);

        if (correoOcupado)
        {
            throw new ConflictException("Ya existe un cliente con ese correo.");
        }

        cliente.Nombre = request.Nombre.Trim();
        cliente.Apellido = request.Apellido.Trim();
        cliente.Telefono = request.Telefono.Trim();
        cliente.Correo = correo;
        cliente.BarberiaId = barberiaId;

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            cliente.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
        }

        if (request.Activo.HasValue)
        {
            // Se protege el Admin único para que no quede inhabilitado por accidente.
            if (string.Equals(cliente.Rol, Roles.Admin, StringComparison.OrdinalIgnoreCase) && request.Activo.Value == false)
            {
                throw new AppValidationException("No se puede desactivar al usuario Admin.");
            }

            cliente.Activo = request.Activo.Value;
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        return mapper.Map<ClienteDto>(cliente);
    }

    public async Task DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var cliente = await dbContext.Clientes
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (cliente is null)
        {
            throw new NotFoundException("El cliente no existe.");
        }

        if (string.Equals(cliente.Rol, Roles.Admin, StringComparison.OrdinalIgnoreCase))
        {
            throw new AppValidationException("No se puede eliminar al usuario Admin.");
        }

        cliente.Activo = false;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task ValidateAsync(CreateClienteAdminRequest request, CancellationToken cancellationToken)
    {
        var validationResult = await createValidator.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            throw new AppValidationException(
                "La solicitud contiene errores de validación.",
                validationResult.Errors.Select(x => x.ErrorMessage).ToArray());
        }
    }

    private async Task ValidateAsync(UpdateClienteAdminRequest request, CancellationToken cancellationToken)
    {
        var validationResult = await updateValidator.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            throw new AppValidationException(
                "La solicitud contiene errores de validación.",
                validationResult.Errors.Select(x => x.ErrorMessage).ToArray());
        }
    }

    private async Task EnsureBarberiaExistsAsync(Guid barberiaId, CancellationToken cancellationToken)
    {
        var exists = await dbContext.Barberias
            .AsNoTracking()
            .AnyAsync(x => x.Id == barberiaId && x.Activa && x.Activo, cancellationToken);

        if (!exists)
        {
            throw new AppValidationException("La barbería seleccionada no existe o está inactiva.");
        }
    }
}
