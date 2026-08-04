using AutoMapper;
using Barberia.Application.DTOs.Barberias;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services.Barberias;
using Barberia.Domain.Enums;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using AppValidationException = Barberia.Application.Exceptions.ValidationException;

namespace Barberia.Application.Services;

public sealed class BarberiaService : IBarberiaService
{
    private readonly IBarberiaDbContext dbContext;
    private readonly IMapper mapper;
    private readonly IValidator<UpsertBarberiaRequest> upsertValidator;

    public BarberiaService(
        IBarberiaDbContext dbContext,
        IMapper mapper,
        IValidator<UpsertBarberiaRequest> upsertValidator)
    {
        this.dbContext = dbContext;
        this.mapper = mapper;
        this.upsertValidator = upsertValidator;
    }

    public async Task<List<BarberiaDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var barberias = await dbContext.Barberias
            .AsNoTracking()
            .Where(x => x.Activo)
            .OrderByDescending(x => x.Activa)
            .ThenBy(x => x.Nombre)
            .ToListAsync(cancellationToken);

        return mapper.Map<List<BarberiaDto>>(barberias);
    }

    public async Task<BarberiaDto> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var barberia = await dbContext.Barberias
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.Activo, cancellationToken);

        if (barberia is null)
        {
            throw new NotFoundException("La barbería solicitada no existe.");
        }

        return mapper.Map<BarberiaDto>(barberia);
    }

    public async Task<BarberiaDto> UpdateAsync(Guid id, UpsertBarberiaRequest request, CancellationToken cancellationToken)
    {
        await ValidateAsync(request, cancellationToken);

        var barberia = await dbContext.Barberias
            .FirstOrDefaultAsync(x => x.Id == id && x.Activo, cancellationToken);

        if (barberia is null)
        {
            throw new NotFoundException("La barbería no existe.");
        }

        barberia.Nombre = request.Nombre.Trim();
        barberia.Descripcion = request.Descripcion?.Trim() ?? string.Empty;
        barberia.Slogan = request.Slogan?.Trim() ?? string.Empty;
        barberia.Telefono = request.Telefono.Trim();
        barberia.Correo = request.Correo.Trim().ToLowerInvariant();
        barberia.SitioWeb = request.SitioWeb?.Trim() ?? string.Empty;
        barberia.Direccion = request.Direccion.Trim();
        barberia.Ciudad = request.Ciudad.Trim();
        barberia.Departamento = request.Departamento.Trim();
        barberia.Pais = request.Pais.Trim();
        barberia.Latitud = request.Latitud;
        barberia.Longitud = request.Longitud;
        barberia.FotoPortada = request.FotoPortada?.Trim() ?? string.Empty;
        barberia.HoraApertura = request.HoraApertura;
        barberia.HoraCierre = request.HoraCierre;
        barberia.DiasDescanso = ParseDiasDescanso(request.DiasDescanso);
        barberia.Activa = request.Activa;

        await dbContext.SaveChangesAsync(cancellationToken);

        return mapper.Map<BarberiaDto>(barberia);
    }

    private async Task ValidateAsync(UpsertBarberiaRequest request, CancellationToken cancellationToken)
    {
        var validationResult = await upsertValidator.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            throw new AppValidationException(
                "La solicitud contiene errores de validación.",
                validationResult.Errors.Select(x => x.ErrorMessage).ToArray());
        }
    }

    public async Task<Guid> GetCurrentBarberiaIdAsync(CancellationToken cancellationToken)
    {
        var id = await dbContext.Barberias
            .AsNoTracking()
            .Where(x => x.Activo && x.Activa)
            .Select(x => x.Id)
            .FirstOrDefaultAsync(cancellationToken);

        if (id == Guid.Empty)
        {
            throw new NotFoundException("No hay una barbería activa configurada.");
        }

        return id;
    }

    private static List<DiaSemana> ParseDiasDescanso(List<string> diasDescanso)
    {
        var result = new List<DiaSemana>();

        foreach (var dia in diasDescanso)
        {
            if (string.IsNullOrWhiteSpace(dia))
            {
                continue;
            }

            if (!Enum.TryParse<DiaSemana>(dia.Trim(), ignoreCase: true, out var parsed))
            {
                throw new AppValidationException($"Día de descanso inválido: {dia}");
            }

            result.Add(parsed);
        }

        return result.Distinct().ToList();
    }
}
