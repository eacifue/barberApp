using Barberia.Application.DTOs.Availability;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services.Availability;
using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using AppValidationException = Barberia.Application.Exceptions.ValidationException;

namespace Barberia.Application.Services;

public class AvailabilityService : IAvailabilityService
{
    private static readonly TimeSpan SlotInterval = TimeSpan.FromMinutes(60);

    private static readonly EstadoCita[] BusyAppointmentStatuses =
    [
        EstadoCita.Pendiente,
        EstadoCita.Confirmada,
        EstadoCita.EnProgreso
    ];

    private readonly IBarberiaDbContext dbContext;
    private readonly IValidator<UpsertBarberAvailabilityRequest> setAvailabilityValidator;

    public AvailabilityService(
        IBarberiaDbContext dbContext,
        IValidator<UpsertBarberAvailabilityRequest> setAvailabilityValidator)
    {
        this.dbContext = dbContext;
        this.setAvailabilityValidator = setAvailabilityValidator;
    }

    public async Task<List<BarberAvailabilityDto>> SetAvailabilityAsync(
        UpsertBarberAvailabilityRequest request,
        CancellationToken cancellationToken)
    {
        var validationResult = await setAvailabilityValidator.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            throw new AppValidationException(
                "La solicitud contiene errores de validación.",
                validationResult.Errors.Select(x => x.ErrorMessage).ToArray());
        }

        await EnsureBarberExistsAsync(request.BarberId, cancellationToken);

        var existing = await dbContext.BarberAvailabilities
            .Where(x => x.BarberId == request.BarberId)
            .ToListAsync(cancellationToken);

        dbContext.BarberAvailabilities.RemoveRange(existing);

        var now = DateTime.UtcNow;
        var mapped = request.Availability.Select(x => new BarberAvailability
        {
            BarberId = request.BarberId,
            DayOfWeek = x.DayOfWeek,
            StartTime = x.StartTime ?? TimeSpan.FromHours(9),
            EndTime = x.EndTime ?? TimeSpan.FromHours(18),
            IsActive = x.IsActive,
            CreatedAt = now,
            UpdatedAt = now,
            Activo = true
        }).ToList();

        await dbContext.BarberAvailabilities.AddRangeAsync(mapped, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);

        return mapped
            .OrderBy(x => x.DayOfWeek)
            .ThenBy(x => x.StartTime)
            .Select(ToDto)
            .ToList();
    }

    public async Task<List<BarberAvailabilityDto>> GetAvailabilityAsync(
        Guid barberId,
        CancellationToken cancellationToken)
    {
        await EnsureBarberExistsAsync(barberId, cancellationToken);

        var availabilities = await dbContext.BarberAvailabilities
            .AsNoTracking()
            .Where(x => x.BarberId == barberId && x.Activo)
            .OrderBy(x => x.DayOfWeek)
            .ThenBy(x => x.StartTime)
            .ToListAsync(cancellationToken);

        if (availabilities.Count > 0)
        {
            return availabilities.Select(ToDto).ToList();
        }

        var legacySchedules = await dbContext.HorariosSemana
            .AsNoTracking()
            .Where(x => x.BarberoId == barberId && x.Activo)
            .OrderBy(x => x.DiaSemana)
            .ThenBy(x => x.HoraInicio)
            .ToListAsync(cancellationToken);

        if (legacySchedules.Count > 0)
        {
            return legacySchedules
                .Select(x => new BarberAvailabilityDto
                {
                    Id = x.Id,
                    BarberId = x.BarberoId,
                    DayOfWeek = ToSystemDayOfWeek(x.DiaSemana),
                    StartTime = x.HoraInicio.ToTimeSpan(),
                    EndTime = x.HoraFin.ToTimeSpan(),
                    IsActive = x.Activo
                })
                .ToList();
        }

        return BuildDefaultAvailability(barberId).Select(ToDto).ToList();
    }

    public async Task<BarberDayOffDto> AddDayOffAsync(
        CreateBarberDayOffRequest request,
        CancellationToken cancellationToken)
    {
        await EnsureBarberExistsAsync(request.BarberId, cancellationToken);

        var exists = await dbContext.BarberDaysOff
            .AnyAsync(x => x.BarberId == request.BarberId && x.Date == request.Date && x.Activo, cancellationToken);

        if (exists)
        {
            throw new AppValidationException("El día no disponible ya existe para este barbero.");
        }

        var entity = new BarberDayOff
        {
            BarberId = request.BarberId,
            Date = request.Date,
            Reason = string.IsNullOrWhiteSpace(request.Reason) ? null : request.Reason.Trim(),
            Activo = true
        };

        await dbContext.BarberDaysOff.AddAsync(entity, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);

        return new BarberDayOffDto
        {
            Id = entity.Id,
            BarberId = entity.BarberId,
            Date = entity.Date,
            Reason = entity.Reason
        };
    }

    public async Task<List<BarberSlotDto>> GetAvailableSlotsAsync(
        Guid barberId,
        DateOnly date,
        CancellationToken cancellationToken)
    {
        await EnsureBarberExistsAsync(barberId, cancellationToken);

        var dayOffExists = await dbContext.BarberDaysOff
            .AsNoTracking()
            .AnyAsync(x => x.BarberId == barberId && x.Date == date && x.Activo, cancellationToken);

        if (dayOffExists)
        {
            return [];
        }

        var ranges = await ResolveRangesAsync(barberId, date, cancellationToken);
        if (ranges.Count == 0)
        {
            return [];
        }

        var appointments = await dbContext.Citas
            .AsNoTracking()
            .Where(x => x.BarberoId == barberId && x.FechaCita == date && BusyAppointmentStatuses.Contains(x.Estado))
            .Select(x => new { x.HoraInicio, x.HoraFin })
            .ToListAsync(cancellationToken);

        var slots = new List<BarberSlotDto>();

        foreach (var (start, end) in ranges)
        {
            var current = start;
            var colombiaZone = TimeZoneInfo.FindSystemTimeZoneById("America/Bogota");
            var nowLocal = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, colombiaZone);
            var todayUtc = DateOnly.FromDateTime(nowLocal);
            var nowTimeUtc = TimeOnly.FromDateTime(nowLocal);
            while (current.Add(SlotInterval) <= end)
            {
                var slotEnd = current.Add(SlotInterval);

                if (date == todayUtc && current <= nowTimeUtc)
                {
                    current = current.Add(SlotInterval);
                    continue;
                }

                var busy = appointments.Any(x => x.HoraInicio < slotEnd && current < x.HoraFin);

                slots.Add(new BarberSlotDto
                {
                    StartTime = current,
                    EndTime = slotEnd,
                    Available = !busy
                });

                current = current.Add(SlotInterval);
            }
        }

        return slots.Where(x => x.Available).ToList();
    }

    private async Task EnsureBarberExistsAsync(Guid barberId, CancellationToken cancellationToken)
    {
        var exists = await dbContext.Barberos
            .AnyAsync(x => x.Id == barberId && x.Activo, cancellationToken);

        if (!exists)
        {
            throw new NotFoundException("El barbero no existe.");
        }
    }

    private async Task<List<(TimeOnly Start, TimeOnly End)>> ResolveRangesAsync(
        Guid barberId,
        DateOnly date,
        CancellationToken cancellationToken)
    {
        var targetDay = date.DayOfWeek;

        var fromNewModel = await dbContext.BarberAvailabilities
            .AsNoTracking()
            .Where(x => x.BarberId == barberId && x.Activo && x.IsActive && x.DayOfWeek == targetDay)
            .OrderBy(x => x.StartTime)
            .Select(x => new ValueTuple<TimeOnly, TimeOnly>(
                TimeOnly.FromTimeSpan(x.StartTime),
                TimeOnly.FromTimeSpan(x.EndTime)))
            .ToListAsync(cancellationToken);

        if (fromNewModel.Count > 0)
        {
            return fromNewModel;
        }

        var legacyDay = ToLegacyDayOfWeek(targetDay);
        var fromLegacy = await dbContext.HorariosSemana
            .AsNoTracking()
            .Where(x => x.BarberoId == barberId && x.Activo && x.DiaSemana == legacyDay)
            .OrderBy(x => x.HoraInicio)
            .Select(x => new ValueTuple<TimeOnly, TimeOnly>(x.HoraInicio, x.HoraFin))
            .ToListAsync(cancellationToken);

        if (fromLegacy.Count > 0)
        {
            return fromLegacy;
        }

        return BuildDefaultAvailability(barberId)
            .Where(x => x.IsActive && x.DayOfWeek == targetDay)
            .Select(x => (
                TimeOnly.FromTimeSpan(x.StartTime),
                TimeOnly.FromTimeSpan(x.EndTime)))
            .ToList();
    }

    private static List<BarberAvailability> BuildDefaultAvailability(Guid barberId)
    {
        var defaults = new List<BarberAvailability>();
        var start = TimeSpan.FromHours(9);
        var end = TimeSpan.FromHours(18);

        foreach (var day in Enum.GetValues<DayOfWeek>())
        {
            defaults.Add(new BarberAvailability
            {
                BarberId = barberId,
                DayOfWeek = day,
                StartTime = start,
                EndTime = end,
                IsActive = day is >= DayOfWeek.Monday and <= DayOfWeek.Friday,
                Activo = true
            });
        }

        return defaults;
    }

    private static BarberAvailabilityDto ToDto(BarberAvailability entity)
    {
        return new BarberAvailabilityDto
        {
            Id = entity.Id,
            BarberId = entity.BarberId,
            DayOfWeek = entity.DayOfWeek,
            StartTime = entity.StartTime,
            EndTime = entity.EndTime,
            IsActive = entity.IsActive
        };
    }

    private static DayOfWeek ToSystemDayOfWeek(DiaSemana day)
    {
        return day switch
        {
            DiaSemana.Lunes => DayOfWeek.Monday,
            DiaSemana.Martes => DayOfWeek.Tuesday,
            DiaSemana.Miercoles => DayOfWeek.Wednesday,
            DiaSemana.Jueves => DayOfWeek.Thursday,
            DiaSemana.Viernes => DayOfWeek.Friday,
            DiaSemana.Sabado => DayOfWeek.Saturday,
            DiaSemana.Domingo => DayOfWeek.Sunday,
            _ => DayOfWeek.Monday
        };
    }

    private static DiaSemana ToLegacyDayOfWeek(DayOfWeek day)
    {
        return day switch
        {
            DayOfWeek.Monday => DiaSemana.Lunes,
            DayOfWeek.Tuesday => DiaSemana.Martes,
            DayOfWeek.Wednesday => DiaSemana.Miercoles,
            DayOfWeek.Thursday => DiaSemana.Jueves,
            DayOfWeek.Friday => DiaSemana.Viernes,
            DayOfWeek.Saturday => DiaSemana.Sabado,
            DayOfWeek.Sunday => DiaSemana.Domingo,
            _ => DiaSemana.Lunes
        };
    }
}
