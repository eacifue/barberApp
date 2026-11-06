using AutoMapper;
using Barberia.Application.DTOs.Citas;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Interfaces.Services.Citas;
using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using AppValidationException = Barberia.Application.Exceptions.ValidationException;

namespace Barberia.Application.Services;

public class CitaService : ICitaService
{
    private static readonly EstadoCita[] EstadosActivos = [EstadoCita.Pendiente, EstadoCita.Confirmada, EstadoCita.EnProgreso];
    private static readonly EstadoCita[] EstadosCancelables = [EstadoCita.Pendiente, EstadoCita.Confirmada];

    private readonly IBarberiaDbContext dbContext;
    private readonly ISlotBloqueoService slotBloqueoService;
    private readonly INotificationService notificationService;
    private readonly ICurrentUserService currentUserService;
    private readonly IValidator<CreateCitaRequest> createValidator;
    private readonly IMapper mapper;

    public CitaService(
        IBarberiaDbContext dbContext,
        ISlotBloqueoService slotBloqueoService,
        INotificationService notificationService,
        ICurrentUserService currentUserService,
        IValidator<CreateCitaRequest> createValidator,
        IMapper mapper)
    {
        this.dbContext = dbContext;
        this.slotBloqueoService = slotBloqueoService;
        this.notificationService = notificationService;
        this.currentUserService = currentUserService;
        this.createValidator = createValidator;
        this.mapper = mapper;
    }

    public async Task<CitaDto> CrearCitaAsync(CreateCitaRequest request, CancellationToken cancellationToken)
    {
        var validationResult = await createValidator.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            throw new AppValidationException("La solicitud contiene errores de validación.", validationResult.Errors.Select(x => x.ErrorMessage).ToArray());
        }

        if (currentUserService.IsCliente && currentUserService.ClienteId != request.ClienteId)
        {
            throw new UnauthorizedException("No puedes crear citas para otro cliente.");
        }

        var cliente = await dbContext.Clientes
            .FirstOrDefaultAsync(x => x.Id == request.ClienteId && x.Activo, cancellationToken);
        if (cliente is null)
        {
            throw new NotFoundException("El cliente no existe.");
        }

        var barbero = await dbContext.Barberos
            .FirstOrDefaultAsync(x => x.Id == request.BarberoId && x.Activo && x.Disponible, cancellationToken);
        if (barbero is null)
        {
            throw new NotFoundException("El barbero no existe o no está disponible.");
        }

        var servicio = await dbContext.Servicios
            .FirstOrDefaultAsync(x => x.Id == request.ServicioId && x.Activo, cancellationToken);
        if (servicio is null)
        {
            throw new NotFoundException("El servicio no existe.");
        }

        var relacion = await dbContext.BarberoServicios
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.BarberoId == request.BarberoId && x.ServicioId == request.ServicioId && x.Activo, cancellationToken);
        if (relacion is null)
        {
            throw new ConflictException("El servicio no pertenece al barbero seleccionado.");
        }

        var colombiaZone = TimeZoneInfo.FindSystemTimeZoneById("America/Bogota");
        var nowLocal = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, colombiaZone);
        var todayLocal = DateOnly.FromDateTime(nowLocal);
        var nowTimeLocal = TimeOnly.FromDateTime(nowLocal);
        if (request.FechaCita < todayLocal
            || (request.FechaCita == todayLocal && request.HoraInicio <= nowTimeLocal))
        {
            throw new ConflictException("No puedes reservar un horario pasado. Selecciona una hora futura.");
        }

        var bloqueo = await slotBloqueoService.ConsultarBloqueoAsync(request.BarberoId, request.FechaCita, request.HoraInicio, cancellationToken);
        if (bloqueo is null || bloqueo.ClienteId != request.ClienteId || !string.Equals(bloqueo.TokenBloqueo, request.TokenRedisBloqueo, StringComparison.Ordinal))
        {
            throw new ConflictException("Este horario ya fue tomado. Intenta con otro.");
        }

        var horaFin = request.HoraInicio.Add(TimeSpan.FromMinutes(servicio.DuracionMinutos));

        var existeConflicto = await dbContext.Citas
            .AsNoTracking()
            .AnyAsync(
                x => x.BarberoId == request.BarberoId &&
                     x.FechaCita == request.FechaCita &&
                     EstadosActivos.Contains(x.Estado) &&
                     x.HoraInicio < horaFin &&
                     request.HoraInicio < x.HoraFin,
                cancellationToken);

        if (existeConflicto)
        {
            throw new ConflictException("Este horario ya fue tomado. Intenta con otro.");
        }

        var precioFinal = relacion.PrecioEspecial ?? servicio.Precio;

        var cita = new Cita
        {
            ClienteId = request.ClienteId,
            BarberoId = request.BarberoId,
            ServicioId = request.ServicioId,
            FechaCita = request.FechaCita,
            HoraInicio = request.HoraInicio,
            HoraFin = horaFin,
            Estado = EstadoCita.Pendiente,
            PrecioFinal = precioFinal,
            TokenRedisBloqueo = request.TokenRedisBloqueo,
            Activo = true
        };

        await dbContext.Citas.AddAsync(cita, cancellationToken);
        cliente.UltimaCita = cita.FechaCita.ToDateTime(cita.HoraInicio, DateTimeKind.Utc);
        cliente.TotalCitas += 1;

        await dbContext.SaveChangesAsync(cancellationToken);
        _ = await slotBloqueoService.LiberarSlotAsync(request.BarberoId, request.FechaCita, request.HoraInicio, request.TokenRedisBloqueo, cancellationToken);

        await notificationService.NotificarNuevaCitaAsync(cita.BarberoId, "Tienes una nueva cita agendada.", cancellationToken);
        await notificationService.NotificarCitaCreadaClienteAsync(cita.ClienteId, "Tu cita fue creada correctamente.", cancellationToken);

        return await GetByIdAsync(cita.Id, cancellationToken);
    }

    public async Task<CitaDto> CancelarCitaAsync(CancelarCitaRequest request, CancellationToken cancellationToken)
    {
        var cita = await GetCitaWithRelationsAsync(request.CitaId, cancellationToken);

        var clienteActualId = currentUserService.ClienteId;
        var esPropietario = currentUserService.IsCliente && clienteActualId == cita.ClienteId;
        if (!currentUserService.IsAdmin && !currentUserService.IsAdminBarberia && !esPropietario)
        {
            throw new UnauthorizedException("No tienes permisos para cancelar esta cita.");
        }

        if (!EstadosCancelables.Contains(cita.Estado))
        {
            throw new ConflictException("Solo se pueden cancelar citas pendientes o confirmadas.");
        }

        cita.Estado = EstadoCita.Cancelada;
        if (!string.IsNullOrWhiteSpace(request.Motivo))
        {
            cita.Notas = string.IsNullOrWhiteSpace(cita.Notas)
                ? $"Cancelación: {request.Motivo.Trim()}"
                : $"{cita.Notas}\nCancelación: {request.Motivo.Trim()}";
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        await notificationService.NotificarCitaCanceladaBarberoAsync(cita.BarberoId, "Una cita fue cancelada.", cancellationToken);
        await notificationService.NotificarCitaCanceladaClienteAsync(cita.ClienteId, "Tu cita fue cancelada correctamente.", cancellationToken);

        return MapCita(cita);
    }

    public async Task<CitaDto> ConfirmarCitaAsync(Guid citaId, CancellationToken cancellationToken)
    {
        var cita = await GetCitaWithRelationsAsync(citaId, cancellationToken);
        if (cita.Estado != EstadoCita.Pendiente)
        {
            throw new ConflictException("Solo se pueden confirmar citas pendientes.");
        }

        cita.Estado = EstadoCita.Confirmada;
        await dbContext.SaveChangesAsync(cancellationToken);
        return MapCita(cita);
    }

    public async Task<CitaDto> CompletarCitaAsync(Guid citaId, CancellationToken cancellationToken)
    {
        var cita = await GetCitaWithRelationsAsync(citaId, cancellationToken);
        if (cita.Estado is not EstadoCita.Confirmada and not EstadoCita.EnProgreso)
        {
            throw new ConflictException("Solo se pueden completar citas confirmadas o en progreso.");
        }

        cita.Estado = EstadoCita.Completada;
        await dbContext.SaveChangesAsync(cancellationToken);
        return MapCita(cita);
    }

    public async Task<List<CitaDto>> GetByClienteAsync(Guid clienteId, CancellationToken cancellationToken)
    {
        if (currentUserService.IsCliente && currentUserService.ClienteId != clienteId)
        {
            throw new UnauthorizedException("No tienes permisos para consultar estas citas.");
        }

        var citas = await dbContext.Citas
            .AsNoTracking()
            .Include(x => x.Cliente)
            .Include(x => x.Barbero)
            .Include(x => x.Servicio)
            .Include(x => x.Review)
            .Where(x => x.ClienteId == clienteId)
            .OrderByDescending(x => x.FechaCita)
            .ThenByDescending(x => x.HoraInicio)
            .ToListAsync(cancellationToken);

        return citas.Select(MapCita).ToList();
    }

    public async Task<List<CitaDto>> GetByBarberoAsync(Guid barberoId, DateOnly fecha, CancellationToken cancellationToken)
    {
        var citas = await dbContext.Citas
            .AsNoTracking()
            .Include(x => x.Cliente)
            .Include(x => x.Barbero)
            .Include(x => x.Servicio)
            .Where(x => x.BarberoId == barberoId && x.FechaCita == fecha)
            .OrderBy(x => x.HoraInicio)
            .ToListAsync(cancellationToken);

        return citas.Select(MapCita).ToList();
    }

    public async Task<List<CitaDto>> GetAdminListAsync(
        Guid? barberoId,
        DateOnly? fechaInicio,
        DateOnly? fechaFin,
        string? estado,
        int page,
        int pageSize,
        CancellationToken cancellationToken)
    {
        var normalizedPage = page < 1 ? 1 : page;
        var normalizedPageSize = Math.Clamp(pageSize, 1, 200);

        Guid? effectiveBarberoId = currentUserService.BarberoId;

        if (currentUserService.IsBarbero)
        {
            var userId = currentUserService.UserId;
            if (userId.HasValue)
            {
                var barberoFromDb = await dbContext.Clientes
                    .IgnoreQueryFilters()
                    .AsNoTracking()
                    .Where(x => x.Id == userId.Value && x.Activo)
                    .Select(x => x.BarberoId)
                    .FirstOrDefaultAsync(cancellationToken);

                if (barberoFromDb.HasValue)
                    effectiveBarberoId = barberoFromDb;
            }
        }

        var query = dbContext.Citas
            .AsNoTracking()
            .IgnoreQueryFilters()
            .Include(x => x.Cliente)
            .Include(x => x.Barbero)
            .Include(x => x.Servicio)
            .AsQueryable();

        if (currentUserService.IsBarbero)
        {
            if (!effectiveBarberoId.HasValue)
                throw new UnauthorizedException("No se pudo resolver el barbero del usuario autenticado.");

            query = query.Where(x => x.BarberoId == effectiveBarberoId.Value);
        }

        if (barberoId.HasValue)
            query = query.Where(x => x.BarberoId == barberoId.Value);

        if (fechaInicio.HasValue)
            query = query.Where(x => x.FechaCita >= fechaInicio.Value);

        if (fechaFin.HasValue)
            query = query.Where(x => x.FechaCita <= fechaFin.Value);

        if (TryParseEstado(estado, out var estadoEnum))
            query = query.Where(x => x.Estado == estadoEnum);

        var citas = await query
            .OrderByDescending(x => x.FechaCita)
            .ThenByDescending(x => x.HoraInicio)
            .Skip((normalizedPage - 1) * normalizedPageSize)
            .Take(normalizedPageSize)
            .ToListAsync(cancellationToken);

        return citas.Select(MapCita).ToList();
    }

    public async Task<CitaDto> GetByIdAsync(Guid citaId, CancellationToken cancellationToken)
    {
        var cita = await GetCitaWithRelationsAsync(citaId, cancellationToken, asNoTracking: true);

        if (currentUserService.IsCliente && currentUserService.ClienteId != cita.ClienteId)
        {
            throw new UnauthorizedException("No tienes permisos para consultar esta cita.");
        }

        return MapCita(cita);
    }

    public async Task<ReviewDto> CrearReviewAsync(Guid citaId, CrearReviewRequest request, CancellationToken cancellationToken)
    {
        var comentario = string.IsNullOrWhiteSpace(request.Comentario) ? null : request.Comentario.Trim();
        var errores = new List<string>();
        if (request.Calificacion is < 1 or > 5)
        {
            errores.Add("La calificación debe estar entre 1 y 5 estrellas.");
        }

        if (comentario is { Length: > 500 })
        {
            errores.Add("El comentario puede tener máximo 500 caracteres.");
        }

        if (errores.Count > 0)
        {
            throw new AppValidationException("La reseña contiene errores de validación.", errores);
        }

        var cita = await GetCitaWithRelationsAsync(citaId, cancellationToken);

        if (!currentUserService.IsCliente || currentUserService.ClienteId != cita.ClienteId)
        {
            throw new UnauthorizedException("Solo puedes calificar tus propias citas.");
        }

        if (cita.Estado != EstadoCita.Completada)
        {
            throw new ConflictException("Solo puedes calificar citas completadas.");
        }

        if (await dbContext.Reviews.IgnoreQueryFilters().AnyAsync(x => x.CitaId == cita.Id, cancellationToken))
        {
            throw new ConflictException("Ya calificaste esta cita.");
        }

        var review = new Review
        {
            ClienteId = cita.ClienteId,
            BarberoId = cita.BarberoId,
            CitaId = cita.Id,
            Calificacion = request.Calificacion,
            Comentario = comentario,
        };
        dbContext.Reviews.Add(review);
        await dbContext.SaveChangesAsync(cancellationToken);

        return new ReviewDto
        {
            Id = review.Id,
            CitaId = review.CitaId,
            BarberoId = review.BarberoId,
            Calificacion = review.Calificacion,
            Comentario = review.Comentario,
            CreatedAt = review.CreatedAt,
        };
    }

    private async Task<Cita> GetCitaWithRelationsAsync(Guid citaId, CancellationToken cancellationToken, bool asNoTracking = false)
    {
        IQueryable<Cita> query = dbContext.Citas
            .IgnoreQueryFilters()
            .Include(x => x.Cliente)
            .Include(x => x.Barbero)
            .Include(x => x.Servicio)
            .Include(x => x.Review);

        if (asNoTracking)
        {
            query = query.AsNoTracking();
        }

        var cita = await query.FirstOrDefaultAsync(x => x.Id == citaId, cancellationToken);
        if (cita is null)
        {
            throw new NotFoundException("La cita no existe.");
        }

        await EnsureCanAccessCitaAsync(cita, cancellationToken);

        return cita;
    }

    private async Task EnsureCanAccessCitaAsync(Cita cita, CancellationToken cancellationToken)
    {
        if (currentUserService.IsAdmin || currentUserService.IsAdminBarberia)
            return;

        if (currentUserService.IsCliente)
        {
            if (currentUserService.ClienteId != cita.ClienteId)
                throw new UnauthorizedException("No tienes permisos para consultar esta cita.");

            return;
        }

        if (currentUserService.IsBarbero)
        {
            var effectiveBarberoId = await ResolveCurrentBarberoIdAsync(cancellationToken);
            if (!effectiveBarberoId.HasValue || cita.BarberoId != effectiveBarberoId.Value)
                throw new NotFoundException("La cita no existe.");
        }
    }

    private async Task<Guid?> ResolveCurrentBarberoIdAsync(CancellationToken cancellationToken)
    {
        if (currentUserService.BarberoId.HasValue)
            return currentUserService.BarberoId;

        var userId = currentUserService.UserId;
        if (!userId.HasValue)
            return null;

        return await dbContext.Clientes
            .IgnoreQueryFilters()
            .AsNoTracking()
            .Where(x => x.Id == userId.Value && x.Activo)
            .Select(x => x.BarberoId)
            .FirstOrDefaultAsync(cancellationToken);
    }

    private static bool TryParseEstado(string? value, out EstadoCita estado)
    {
        estado = default;
        if (string.IsNullOrWhiteSpace(value))
            return false;

        var normalized = value.Trim().ToLowerInvariant();
        return normalized switch
        {
            "pendiente" or "pending" => SetEstado(EstadoCita.Pendiente, out estado),
            "confirmada" or "confirmado" or "confirmed" => SetEstado(EstadoCita.Confirmada, out estado),
            "enprogreso" or "en_progreso" or "inprogress" => SetEstado(EstadoCita.EnProgreso, out estado),
            "completada" or "completed" => SetEstado(EstadoCita.Completada, out estado),
            "cancelada" or "cancelled" or "canceled" => SetEstado(EstadoCita.Cancelada, out estado),
            "noshow" => SetEstado(EstadoCita.NoShow, out estado),
            _ => false,
        };
    }

    private static bool SetEstado(EstadoCita value, out EstadoCita estado)
    {
        estado = value;
        return true;
    }

    private CitaDto MapCita(Cita cita)
    {
        var dto = mapper.Map<CitaDto>(cita);
        dto.Cliente = mapper.Map<ClienteCitaDto>(cita.Cliente);
        dto.Barbero = mapper.Map<BarberoCitaDto>(cita.Barbero);
        dto.Servicio = mapper.Map<ServicioCitaDto>(cita.Servicio);
        return dto;
    }
}
