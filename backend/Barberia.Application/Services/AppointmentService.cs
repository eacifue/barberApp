using AutoMapper;
using Barberia.Application.DTOs.Appointments;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Persistence;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services;
using Barberia.Domain.Entities;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Barberia.Application.Services;

public class AppointmentService : IAppointmentService
{
    private readonly IAppointmentRepository appointmentRepository;
    private readonly IBarberiaDbContext barberiaDbContext;
    private readonly ICacheService cacheService;
    private readonly INotificationService notificationService;
    private readonly IMapper mapper;
    private readonly ICurrentUserService currentUserService;
    private readonly ILogger<AppointmentService> logger;
    private readonly IValidator<CreateAppointmentRequest> createValidator;
    private const int BlockTtlMinutes = 5;
    private static readonly TimeSpan LockTtl = TimeSpan.FromMinutes(BlockTtlMinutes + 1);

    public AppointmentService(
        IAppointmentRepository appointmentRepository,
        IBarberiaDbContext barberiaDbContext,
        ICacheService cacheService,
        INotificationService notificationService,
        IMapper mapper,
        ICurrentUserService currentUserService,
        ILogger<AppointmentService> logger,
        IValidator<CreateAppointmentRequest> createValidator)
    {
        this.appointmentRepository = appointmentRepository;
        this.barberiaDbContext = barberiaDbContext;
        this.cacheService = cacheService;
        this.notificationService = notificationService;
        this.mapper = mapper;
        this.currentUserService = currentUserService;
        this.logger = logger;
        this.createValidator = createValidator;
    }

    public async Task<AppointmentResponse> CreateAsync(CreateAppointmentRequest request, CancellationToken cancellationToken)
    {
        var clienteId = request.ResolveClienteId();
        var startTimeUtc = request.ResolveStartTimeUtc();
        var endTimeUtc = request.ResolveEndTimeUtc();

        var validationResult = await createValidator.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            throw new Exceptions.ValidationException(
                "La solicitud no cumple las reglas de validación.",
                validationResult.Errors.Select(x => x.ErrorMessage).ToArray());
        }

        if (currentUserService.IsCliente)
        {
            if (currentUserService.ClienteId is null)
            {
                throw new UnauthorizedException("No se pudo identificar al cliente autenticado.");
            }

            if (currentUserService.ClienteId != clienteId)
            {
                throw new UnauthorizedException("No puedes crear citas para otro cliente.");
            }
        }

        logger.LogInformation(
            "Creando cita para cliente {ClienteId}, barbero {BarberoId}, inicio {StartTimeUtc}, fin {EndTimeUtc}",
            clienteId,
            request.BarberoId,
            startTimeUtc,
            endTimeUtc);

        var barberoExists = await barberiaDbContext.Barberos
            .AsNoTracking()
            .AnyAsync(b => b.Id == request.BarberoId, cancellationToken);

        if (!barberoExists)
        {
            logger.LogWarning("Barbero {BarberoId} no encontrado", request.BarberoId);
            throw new NotFoundException($"El barbero con id {request.BarberoId} no existe.");
        }

        var lockKey = $"appointment:block:{request.BarberoId}:{startTimeUtc:yyyyMMddHHmm}";
        var isBlocked = await cacheService.ExistsAsync(lockKey, cancellationToken);
        if (isBlocked)
        {
            logger.LogWarning("Bloqueo temporal detectado para llave {LockKey}", lockKey);
            throw new ConflictException("El horario seleccionado está temporalmente bloqueado. Intenta nuevamente.");
        }

        var hasOverlap = await appointmentRepository.HasOverlapAsync(
            request.BarberoId,
            startTimeUtc,
            endTimeUtc,
            cancellationToken);

        if (hasOverlap)
        {
            logger.LogWarning("Solapamiento detectado para barbero {BarberoId} entre {StartTimeUtc} y {EndTimeUtc}", request.BarberoId, startTimeUtc, endTimeUtc);
            throw new ConflictException("Ya existe una cita en el horario seleccionado.");
        }

        await cacheService.SetAsync(lockKey, "1", TimeSpan.FromMinutes(BlockTtlMinutes), cancellationToken);

        var clienteLockSetKey = $"appointment:cliente:{clienteId}:locks";
        await cacheService.AddToSetAsync(clienteLockSetKey, lockKey, LockTtl, cancellationToken);

        var appointment = mapper.Map<Appointment>(request);
        appointment.Id = Guid.NewGuid();
        appointment.ClienteId = clienteId;
        appointment.StartTimeUtc = startTimeUtc;
        appointment.EndTimeUtc = endTimeUtc;

        var created = await appointmentRepository.AddAsync(appointment, cancellationToken);

        logger.LogInformation("Cita {AppointmentId} creada correctamente para cliente {ClienteId}", created.Id, created.ClienteId);

        await notificationService.SendAppointmentCreatedAsync(
            created.ClienteId,
            "Tu cita fue registrada correctamente.",
            cancellationToken);

        return mapper.Map<AppointmentResponse>(created);
    }

    public async Task<AppointmentResponse> GetByIdAsync(Guid appointmentId, CancellationToken cancellationToken)
    {
        logger.LogDebug("Consultando cita por id {AppointmentId}", appointmentId);
        var appointment = await appointmentRepository.GetByIdAsync(appointmentId, cancellationToken);
        if (appointment is null)
        {
            throw new NotFoundException("La cita solicitada no existe.");
        }

        return mapper.Map<AppointmentResponse>(appointment);
    }

    public async Task<IReadOnlyList<AppointmentResponse>> GetByClienteAsync(Guid clienteId, CancellationToken cancellationToken)
    {
        if (currentUserService.IsCliente && currentUserService.ClienteId != clienteId)
        {
            throw new UnauthorizedException("No tienes permisos para consultar citas de otro cliente.");
        }

        logger.LogDebug("Consultando citas para cliente {ClienteId}", clienteId);
        var appointments = await appointmentRepository.GetByClienteAsync(clienteId, cancellationToken);
        return appointments.Select(mapper.Map<AppointmentResponse>).ToList();
    }
}
