using AutoMapper;
using Barberia.Application.DTOs.Barberos;
using Barberia.Application.DTOs.Servicios;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services.Barberos;
using Barberia.Domain.Entities;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using AppValidationException = Barberia.Application.Exceptions.ValidationException;

namespace Barberia.Application.Services;

public class BarberoService : IBarberoService
{
    private readonly IBarberiaDbContext dbContext;
    private readonly IMapper mapper;
    private readonly IValidator<CreateBarberoRequest> createBarberoValidator;
    private readonly IValidator<SetHorarioRequest> setHorarioValidator;

    public BarberoService(
        IBarberiaDbContext dbContext,
        IMapper mapper,
        IValidator<CreateBarberoRequest> createBarberoValidator,
        IValidator<SetHorarioRequest> setHorarioValidator)
    {
        this.dbContext = dbContext;
        this.mapper = mapper;
        this.createBarberoValidator = createBarberoValidator;
        this.setHorarioValidator = setHorarioValidator;
    }

    public async Task<List<BarberoDto>> GetAllByBarberiaAsync(Guid barberiaId, CancellationToken cancellationToken)
    {
        var barberos = await dbContext.Barberos
            .AsNoTracking()
            .Where(x => x.BarberiaId == barberiaId && x.Activo)
            .OrderBy(x => x.Nombre)
            .ThenBy(x => x.Apellido)
            .ToListAsync(cancellationToken);

        return await BuildBarberoDtosAsync(barberos, cancellationToken);
    }

    public async Task<BarberoDto> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var barbero = await dbContext.Barberos
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (barbero is null)
        {
            throw new NotFoundException("El barbero solicitado no existe.");
        }

        var result = await BuildBarberoDtosAsync([barbero], cancellationToken);
        return result[0];
    }

    public async Task<List<BarberoDto>> GetByServicioAsync(Guid servicioId, CancellationToken cancellationToken)
    {
        var barberos = await dbContext.BarberoServicios
            .AsNoTracking()
            .Where(x => x.ServicioId == servicioId && x.Activo && x.Barbero.Disponible && x.Barbero.Activo)
            .Select(x => x.Barbero)
            .Distinct()
            .OrderBy(x => x.Nombre)
            .ThenBy(x => x.Apellido)
            .ToListAsync(cancellationToken);

        return await BuildBarberoDtosAsync(barberos, cancellationToken);
    }

    public async Task<BarberoDto> CreateAsync(CreateBarberoRequest request, CancellationToken cancellationToken)
    {
        await ValidateCreateOrUpdateAsync(request, cancellationToken);

        var barberiaExiste = await dbContext.Barberias
            .AnyAsync(x => x.Id == request.BarberiaId && x.Activa && x.Activo, cancellationToken);

        if (!barberiaExiste)
        {
            throw new NotFoundException("La barbería indicada no existe o está inactiva.");
        }

        var servicioIds = request.ServicioIds.Distinct().ToList();
        var serviciosValidos = await dbContext.Servicios
            .Where(x => servicioIds.Contains(x.Id) && x.BarberiaId == request.BarberiaId && x.Activo)
            .Select(x => x.Id)
            .ToListAsync(cancellationToken);

        if (serviciosValidos.Count != servicioIds.Count)
        {
            throw new AppValidationException("Uno o más servicios no son válidos para la barbería indicada.");
        }

        var barbero = new Barbero
        {
            BarberiaId = request.BarberiaId,
            Nombre = request.Nombre.Trim(),
            Apellido = request.Apellido.Trim(),
            Telefono = request.Telefono.Trim(),
            Correo = request.Correo.Trim(),
            FotoUrl = request.FotoUrl,
            Biografia = request.Biografia?.Trim() ?? string.Empty,
            AniosExperiencia = request.AniosExperiencia,
            Especialidades = request.Especialidades.Select(x => x.Trim()).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct().ToList(),
            Disponible = true,
            Activo = true
        };

        await dbContext.Barberos.AddAsync(barbero, cancellationToken);

        foreach (var servicioId in servicioIds)
        {
            await dbContext.BarberoServicios.AddAsync(new BarberoServicio
            {
                Barbero = barbero,
                ServicioId = servicioId,
                Activo = true
            }, cancellationToken);
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(barbero.Id, cancellationToken);
    }

    public async Task<BarberoDto> UpdateAsync(Guid id, CreateBarberoRequest request, CancellationToken cancellationToken)
    {
        await ValidateCreateOrUpdateAsync(request, cancellationToken);

        var barbero = await dbContext.Barberos
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (barbero is null)
        {
            throw new NotFoundException("El barbero no existe.");
        }

        var servicioIds = request.ServicioIds.Distinct().ToList();
        var serviciosValidos = await dbContext.Servicios
            .Where(x => servicioIds.Contains(x.Id) && x.BarberiaId == request.BarberiaId && x.Activo)
            .Select(x => x.Id)
            .ToListAsync(cancellationToken);

        if (serviciosValidos.Count != servicioIds.Count)
        {
            throw new AppValidationException("Uno o más servicios no son válidos para la barbería indicada.");
        }

        barbero.BarberiaId = request.BarberiaId;
        barbero.Nombre = request.Nombre.Trim();
        barbero.Apellido = request.Apellido.Trim();
        barbero.Telefono = request.Telefono.Trim();
        barbero.Correo = request.Correo.Trim();
        barbero.FotoUrl = request.FotoUrl;
        barbero.Biografia = request.Biografia?.Trim() ?? string.Empty;
        barbero.AniosExperiencia = request.AniosExperiencia;
        barbero.Especialidades = request.Especialidades.Select(x => x.Trim()).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct().ToList();

        var relaciones = await dbContext.BarberoServicios
            .Where(x => x.BarberoId == barbero.Id)
            .ToListAsync(cancellationToken);

        foreach (var relacion in relaciones)
        {
            relacion.Activo = servicioIds.Contains(relacion.ServicioId);
        }

        var actuales = relaciones.Select(x => x.ServicioId).ToHashSet();
        var nuevos = servicioIds.Where(x => !actuales.Contains(x));

        foreach (var nuevoServicioId in nuevos)
        {
            await dbContext.BarberoServicios.AddAsync(new BarberoServicio
            {
                BarberoId = barbero.Id,
                ServicioId = nuevoServicioId,
                Activo = true
            }, cancellationToken);
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(barbero.Id, cancellationToken);
    }

    public async Task DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var barbero = await dbContext.Barberos
            .FirstOrDefaultAsync(x => x.Id == id && x.Activo, cancellationToken);

        if (barbero is null)
        {
            throw new NotFoundException("El barbero no existe.");
        }

        barbero.Activo = false;
        barbero.Disponible = false;

        var relaciones = await dbContext.BarberoServicios
            .Where(x => x.BarberoId == id && x.Activo)
            .ToListAsync(cancellationToken);

        foreach (var relacion in relaciones)
        {
            relacion.Activo = false;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task AsignarServicioAsync(Guid barberoId, Guid servicioId, CancellationToken cancellationToken)
    {
        var barbero = await dbContext.Barberos
            .FirstOrDefaultAsync(x => x.Id == barberoId && x.Activo, cancellationToken);

        if (barbero is null)
        {
            throw new NotFoundException("El barbero no existe.");
        }

        var servicio = await dbContext.Servicios
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == servicioId && x.Activo, cancellationToken);

        if (servicio is null)
        {
            throw new NotFoundException("El servicio no existe.");
        }

        if (servicio.BarberiaId != barbero.BarberiaId)
        {
            throw new AppValidationException("No es posible asignar un servicio de otra barbería.");
        }

        var relacion = await dbContext.BarberoServicios
            .FirstOrDefaultAsync(x => x.BarberoId == barberoId && x.ServicioId == servicioId, cancellationToken);

        if (relacion is null)
        {
            await dbContext.BarberoServicios.AddAsync(new BarberoServicio
            {
                BarberoId = barberoId,
                ServicioId = servicioId,
                Activo = true
            }, cancellationToken);
        }
        else
        {
            relacion.Activo = true;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<List<HorarioSemanaDto>> SetHorariosAsync(SetHorarioRequest request, CancellationToken cancellationToken)
    {
        var validationResult = await setHorarioValidator.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            throw new AppValidationException(
                "La solicitud contiene errores de validación.",
                validationResult.Errors.Select(x => x.ErrorMessage).ToArray());
        }

        var barberoExiste = await dbContext.Barberos
            .AnyAsync(x => x.Id == request.BarberoId && x.Activo, cancellationToken);

        if (!barberoExiste)
        {
            throw new NotFoundException("El barbero no existe.");
        }

        var diasSolicitados = request.Horarios.Select(x => x.DiaSemana).Distinct().ToList();

        var existentes = await dbContext.HorariosSemana
            .Where(x => x.BarberoId == request.BarberoId && diasSolicitados.Contains(x.DiaSemana))
            .ToListAsync(cancellationToken);

        dbContext.HorariosSemana.RemoveRange(existentes);

        var nuevos = request.Horarios.Select(x => new HorarioSemana
        {
            BarberoId = request.BarberoId,
            DiaSemana = x.DiaSemana,
            HoraInicio = x.HoraInicio,
            HoraFin = x.HoraFin,
            IntervaloCitasMinutos = x.IntervaloCitas,
            Activo = true
        }).ToList();

        await dbContext.HorariosSemana.AddRangeAsync(nuevos, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);

        return mapper.Map<List<HorarioSemanaDto>>(nuevos.OrderBy(x => x.DiaSemana).ThenBy(x => x.HoraInicio).ToList());
    }

    public async Task<List<HorarioSemanaDto>> GetHorariosAsync(Guid barberoId, CancellationToken cancellationToken)
    {
        var existe = await dbContext.Barberos
            .AnyAsync(x => x.Id == barberoId && x.Activo, cancellationToken);

        if (!existe)
        {
            throw new NotFoundException("El barbero no existe.");
        }

        var horarios = await dbContext.HorariosSemana
            .AsNoTracking()
            .Where(x => x.BarberoId == barberoId && x.Activo)
            .OrderBy(x => x.DiaSemana)
            .ThenBy(x => x.HoraInicio)
            .ToListAsync(cancellationToken);

        return mapper.Map<List<HorarioSemanaDto>>(horarios);
    }

    public async Task UpdateTokenFCMAsync(Guid barberoId, string token, CancellationToken cancellationToken)
    {
        var barbero = await dbContext.Barberos
            .FirstOrDefaultAsync(x => x.Id == barberoId && x.Activo, cancellationToken);

        if (barbero is null)
        {
            throw new NotFoundException("El barbero no existe.");
        }

        barbero.TokenFCM = string.IsNullOrWhiteSpace(token) ? null : token.Trim();
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task ValidateCreateOrUpdateAsync(CreateBarberoRequest request, CancellationToken cancellationToken)
    {
        var validationResult = await createBarberoValidator.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            throw new AppValidationException(
                "La solicitud contiene errores de validación.",
                validationResult.Errors.Select(x => x.ErrorMessage).ToArray());
        }
    }

    private async Task<List<BarberoDto>> BuildBarberoDtosAsync(List<Barbero> barberos, CancellationToken cancellationToken)
    {
        if (barberos.Count == 0)
        {
            return [];
        }

        var barberoIds = barberos.Select(x => x.Id).ToList();

        var serviciosPorBarbero = await dbContext.BarberoServicios
            .AsNoTracking()
            .Where(x => barberoIds.Contains(x.BarberoId) && x.Activo && x.Servicio.Activo)
            .Select(x => new { x.BarberoId, Servicio = x.Servicio })
            .ToListAsync(cancellationToken);

        var ratings = await dbContext.Reviews
            .AsNoTracking()
            .Where(x => barberoIds.Contains(x.BarberoId) && x.Visible)
            .GroupBy(x => x.BarberoId)
            .Select(x => new { BarberoId = x.Key, Rating = x.Average(r => (decimal)r.Calificacion) })
            .ToDictionaryAsync(x => x.BarberoId, x => Math.Round(x.Rating, 2), cancellationToken);

        var servicioLookup = serviciosPorBarbero
            .GroupBy(x => x.BarberoId)
            .ToDictionary(
                x => x.Key,
                x => mapper.Map<List<ServicioDto>>(x.Select(item => item.Servicio).Distinct().OrderBy(s => s.Nombre).ToList()));

        var result = mapper.Map<List<BarberoDto>>(barberos);

        foreach (var dto in result)
        {
            dto.RatingPromedio = ratings.TryGetValue(dto.Id, out var rating) ? rating : 0;
            dto.Servicios = servicioLookup.TryGetValue(dto.Id, out var servicios) ? servicios : new List<ServicioDto>();
        }

        return result;
    }
}
