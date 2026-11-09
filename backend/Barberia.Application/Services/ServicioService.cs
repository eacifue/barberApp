using Barberia.Application.Interfaces.Services.Barberias;
using AutoMapper;
using Barberia.Application.DTOs.Servicios;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services.Servicios;
using Barberia.Domain.Entities;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using AppValidationException = Barberia.Application.Exceptions.ValidationException;

namespace Barberia.Application.Services;

public class ServicioService : IServicioService
{
    private readonly IBarberiaDbContext dbContext;
    private readonly IMapper mapper;
    private readonly IValidator<CreateServicioRequest> createValidator;
    private readonly IBarberiaContexto barberiaContexto;

    public ServicioService(
        IBarberiaDbContext dbContext,
        IMapper mapper,
        IValidator<CreateServicioRequest> createValidator,
        IBarberiaContexto barberiaContexto)
    {
        this.barberiaContexto = barberiaContexto;
        this.dbContext = dbContext;
        this.mapper = mapper;
        this.createValidator = createValidator;
    }

    public async Task<List<ServicioDto>> GetAllByBarberiaAsync(Guid barberiaId, CancellationToken cancellationToken, bool incluirInactivos = false)
    {
        var servicios = await dbContext.Servicios
            .AsNoTracking()
            .Where(x => incluirInactivos || x.Activo)
            .OrderBy(x => x.Nombre)
            .ToListAsync(cancellationToken);

        return mapper.Map<List<ServicioDto>>(servicios);
    }

    public async Task<ServicioDto> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var servicio = await dbContext.Servicios
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (servicio is null)
        {
            throw new NotFoundException("El servicio solicitado no existe.");
        }

        return mapper.Map<ServicioDto>(servicio);
    }

    public async Task<ServicioDto> CreateAsync(CreateServicioRequest request, CancellationToken cancellationToken)
    {
        await ValidateCreateOrUpdateAsync(request, cancellationToken);

        var servicio = new Servicio
        {
            BarberiaId = await barberiaContexto.ObtenerIdAsync(cancellationToken),
            Nombre = request.Nombre.Trim(),
            Descripcion = request.Descripcion.Trim(),
            Tipo = request.Tipo,
            DuracionMinutos = request.DuracionMinutos,
            Precio = request.Precio,
            FotoUrl = request.FotoUrl,
            Activo = true
        };

        await dbContext.Servicios.AddAsync(servicio, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);

        return mapper.Map<ServicioDto>(servicio);
    }

    public async Task<ServicioDto> UpdateAsync(Guid id, CreateServicioRequest request, CancellationToken cancellationToken)
    {
        await ValidateCreateOrUpdateAsync(request, cancellationToken);

        var servicio = await dbContext.Servicios
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (servicio is null)
        {
            throw new NotFoundException("El servicio no existe.");
        }

        servicio.Nombre = request.Nombre.Trim();
        servicio.Descripcion = request.Descripcion.Trim();
        servicio.Tipo = request.Tipo;
        servicio.DuracionMinutos = request.DuracionMinutos;
        servicio.Precio = request.Precio;
        servicio.FotoUrl = request.FotoUrl;

        await dbContext.SaveChangesAsync(cancellationToken);

        return mapper.Map<ServicioDto>(servicio);
    }

    public async Task DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var servicio = await dbContext.Servicios
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (servicio is null)
        {
            throw new NotFoundException("El servicio no existe.");
        }

        servicio.Activo = false;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<List<ServicioDto>> GetByBarberoAsync(Guid barberoId, CancellationToken cancellationToken)
    {
        var servicios = await dbContext.BarberoServicios
            .AsNoTracking()
            .Where(x => x.BarberoId == barberoId && x.Activo && x.Servicio.Activo)
            .Select(x => x.Servicio)
            .OrderBy(x => x.Nombre)
            .ToListAsync(cancellationToken);

        return mapper.Map<List<ServicioDto>>(servicios);
    }

    private async Task ValidateCreateOrUpdateAsync(CreateServicioRequest request, CancellationToken cancellationToken)
    {
        var validationResult = await createValidator.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            throw new AppValidationException(
                "La solicitud contiene errores de validación.",
                validationResult.Errors.Select(x => x.ErrorMessage).ToArray());
        }
    }

    public async Task<ServicioDto> ActivarAsync(Guid id, CancellationToken cancellationToken)
    {
        var servicio = await dbContext.Servicios
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (servicio is null)
        {
            throw new NotFoundException("El servicio no existe.");
        }

        servicio.Activo = true;
        await dbContext.SaveChangesAsync(cancellationToken);
        return mapper.Map<ServicioDto>(servicio);
    }
}
