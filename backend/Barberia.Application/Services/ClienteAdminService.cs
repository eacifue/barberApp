using Barberia.Application.Interfaces.Services.Barberias;
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
    private readonly IBarberiaContexto barberiaContexto;

    public ClienteAdminService(
        IBarberiaDbContext dbContext,
        IMapper mapper,
        IValidator<CreateClienteAdminRequest> createValidator,
        IValidator<UpdateClienteAdminRequest> updateValidator,
        IBarberiaContexto barberiaContexto)
    {
        this.barberiaContexto = barberiaContexto;
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

        return mapper.Map<List<ClienteDto>>(clientes);
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

        return mapper.Map<ClienteDto>(cliente);
    }

    public async Task<ClienteDto> CreateAsync(CreateClienteAdminRequest request, CancellationToken cancellationToken)
    {
        await ValidateAsync(request, cancellationToken);

        var correo = request.Correo.Trim().ToLowerInvariant();
        var barberiaId = await barberiaContexto.ObtenerIdAsync(cancellationToken);
        var existe = await dbContext.Clientes.IgnoreQueryFilters().AnyAsync(x => x.Correo == correo && x.BarberiaId == barberiaId, cancellationToken);
        if (existe)
        {
            throw new ConflictException("Ya existe un cliente con ese correo.");
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

        return mapper.Map<ClienteDto>(cliente);
    }

    public async Task<ClienteDto> UpdateAsync(Guid id, UpdateClienteAdminRequest request, CancellationToken cancellationToken)
    {
        await ValidateAsync(request, cancellationToken);

        var cliente = await dbContext.Clientes
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (cliente is null)
        {
            throw new NotFoundException("El cliente no existe.");
        }

        var correo = request.Correo.Trim().ToLowerInvariant();
        var correoOcupado = await dbContext.Clientes
            .IgnoreQueryFilters()
            .AnyAsync(x => x.Id != id && x.Correo == correo && x.BarberiaId == cliente.BarberiaId, cancellationToken);

        if (correoOcupado)
        {
            throw new ConflictException("Ya existe un cliente con ese correo.");
        }

        cliente.Nombre = request.Nombre.Trim();
        cliente.Apellido = request.Apellido.Trim();
        cliente.Telefono = request.Telefono.Trim();
        cliente.Correo = correo;

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
}
