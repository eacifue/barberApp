using Barberia.Application.DTOs.Disponibilidad;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services.Disponibilidad;
using Barberia.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Application.Services;

public class DisponibilidadService : IDisponibilidadService
{
    private const int SlotIntervalMinutes = 60;

    private sealed class HorarioRange
    {
        public required TimeOnly HoraInicio { get; init; }

        public required TimeOnly HoraFin { get; init; }

        public required int IntervaloCitasMinutos { get; init; }
    }

    private static readonly EstadoCita[] EstadosOcupados =
    [
        EstadoCita.Pendiente,
        EstadoCita.Confirmada,
        EstadoCita.EnProgreso
    ];

    private readonly IBarberiaDbContext dbContext;
    private readonly ISlotBloqueoService slotBloqueoService;

    public DisponibilidadService(IBarberiaDbContext dbContext, ISlotBloqueoService slotBloqueoService)
    {
        this.dbContext = dbContext;
        this.slotBloqueoService = slotBloqueoService;
    }

    public async Task<DisponibilidadBarberoDto> GetSlotsDisponiblesAsync(
        Guid barberoId,
        Guid servicioId,
        DateOnly fecha,
        CancellationToken cancellationToken)
    {
        var barbero = await dbContext.Barberos
            .AsNoTracking()
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

        var response = new DisponibilidadBarberoDto
        {
            BarberoId = barbero.Id,
            BarberoNombre = $"{barbero.Nombre} {barbero.Apellido}".Trim(),
            ServicioId = servicio.Id,
            DuracionServicioMin = servicio.DuracionMinutos,
            Fecha = fecha,
            Slots = []
        };

        var isDayOff = await dbContext.BarberDaysOff
            .AsNoTracking()
            .AnyAsync(x => x.BarberId == barberoId && x.Date == fecha && x.Activo, cancellationToken);

        if (isDayOff)
        {
            return response;
        }

        var diaSemana = ToDiaSemana(fecha.DayOfWeek);

        var horariosNuevos = await dbContext.BarberAvailabilities
            .AsNoTracking()
            .Where(x => x.BarberId == barberoId && x.DayOfWeek == fecha.DayOfWeek && x.Activo && x.IsActive)
            .OrderBy(x => x.StartTime)
            .Select(x => new HorarioRange
            {
                HoraInicio = TimeOnly.FromTimeSpan(x.StartTime),
                HoraFin = TimeOnly.FromTimeSpan(x.EndTime),
                IntervaloCitasMinutos = SlotIntervalMinutes
            })
            .ToListAsync(cancellationToken);

        var horariosLegacy = await dbContext.HorariosSemana
            .AsNoTracking()
            .Where(x => x.BarberoId == barberoId && x.DiaSemana == diaSemana && x.Activo)
            .OrderBy(x => x.HoraInicio)
            .Select(x => new HorarioRange
            {
                HoraInicio = x.HoraInicio,
                HoraFin = x.HoraFin,
                IntervaloCitasMinutos = SlotIntervalMinutes
            })
            .ToListAsync(cancellationToken);

        var horarios = horariosNuevos.Count > 0
            ? horariosNuevos
            : horariosLegacy.Count > 0
                ? horariosLegacy
                : BuildDefaultRanges(fecha.DayOfWeek);

        if (horarios.Count == 0)
        {
            return response;
        }

        var fechaInicio = fecha.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);
        var fechaFin = fecha.ToDateTime(TimeOnly.MaxValue, DateTimeKind.Utc);

        var tieneBloqueo = await dbContext.BloqueosHorario
            .AsNoTracking()
            .AnyAsync(
                x => x.BarberoId == barberoId &&
                     x.Activo &&
                     x.FechaInicio <= fechaFin &&
                     x.FechaFin >= fechaInicio,
                cancellationToken);

        if (tieneBloqueo)
        {
            return response;
        }

        var citasOcupadas = await dbContext.Citas
            .AsNoTracking()
            .Where(
                x => x.BarberoId == barberoId &&
                     x.FechaCita == fecha &&
                     EstadosOcupados.Contains(x.Estado))
            .Select(x => new { x.HoraInicio, x.HoraFin })
            .ToListAsync(cancellationToken);

        foreach (var horario in horarios)
        {
            var slotStart = horario.HoraInicio;
            var baseInterval = TimeSpan.FromMinutes(SlotIntervalMinutes);
            var duracionServicio = TimeSpan.FromMinutes(servicio.DuracionMinutos);
            var colombiaZone = TimeZoneInfo.FindSystemTimeZoneById("America/Bogota");
            var nowLocal = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, colombiaZone);
            var todayUtc = DateOnly.FromDateTime(nowLocal);
            var nowTimeUtc = TimeOnly.FromDateTime(nowLocal);

            while (slotStart < horario.HoraFin)
            {
                var slotEnd = slotStart.Add(duracionServicio);
                if (slotEnd > horario.HoraFin)
                {
                    break;
                }

                if (fecha == todayUtc && slotStart <= nowTimeUtc)
                {
                    slotStart = slotStart.Add(baseInterval);
                    continue;
                }

                var ocupado = citasOcupadas.Any(cita => cita.HoraInicio < slotEnd && slotStart < cita.HoraFin);

                var bloqueo = await slotBloqueoService.ConsultarBloqueoAsync(barberoId, fecha, slotStart, cancellationToken);
                var minutosRestantesBloqueo = bloqueo?.MinutosRestantes;
                var bloqueadoPorRedis = bloqueo is not null;

                response.Slots.Add(new SlotDisponibleDto
                {
                    FechaCita = fecha,
                    HoraInicio = slotStart,
                    HoraFin = slotEnd,
                    Disponible = !ocupado && !bloqueadoPorRedis,
                    BloqueadoPorRedis = bloqueadoPorRedis,
                    MinutosRestantesBloqueo = minutosRestantesBloqueo
                });

                slotStart = slotStart.Add(baseInterval);
            }
        }

        return response;
    }

    private static List<HorarioRange> BuildDefaultRanges(DayOfWeek dayOfWeek)
    {
        if (dayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday)
        {
            return [];
        }

        return
        [
            new HorarioRange
            {
                HoraInicio = new TimeOnly(9, 0),
                HoraFin = new TimeOnly(18, 0),
                IntervaloCitasMinutos = SlotIntervalMinutes
            }
        ];
    }

    private static DiaSemana ToDiaSemana(DayOfWeek dayOfWeek)
    {
        return dayOfWeek switch
        {
            DayOfWeek.Monday => DiaSemana.Lunes,
            DayOfWeek.Tuesday => DiaSemana.Martes,
            DayOfWeek.Wednesday => DiaSemana.Miercoles,
            DayOfWeek.Thursday => DiaSemana.Jueves,
            DayOfWeek.Friday => DiaSemana.Viernes,
            DayOfWeek.Saturday => DiaSemana.Sabado,
            DayOfWeek.Sunday => DiaSemana.Domingo,
            _ => throw new ArgumentOutOfRangeException(nameof(dayOfWeek), "Día de semana no válido.")
        };
    }
}
