using Barberia.Application.DTOs.Slots;
using Barberia.Application.Exceptions;
using Barberia.Application.Interfaces;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Interfaces.Services.Slots;
using Microsoft.EntityFrameworkCore;

namespace Barberia.Application.Services;

/// <summary>
/// Reservas en curso para recepción. Los bloqueos viven en Redis sin datos de
/// negocio; aquí se cruzan con barberos (filtro de tenant) y clientes.
/// </summary>
public sealed class ReservasEnCursoService(
    IBarberiaDbContext dbContext,
    ISlotBloqueoService slotBloqueoService,
    INotificationService notificationService,
    TimeProvider timeProvider) : IReservasEnCursoService
{
    private static readonly string[] Dias = ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"];
    private static readonly string[] Meses = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];

    public async Task<IReadOnlyList<ReservaEnCursoDto>> ListarAsync(CancellationToken cancellationToken)
    {
        var ahora = timeProvider.GetUtcNow().UtcDateTime;
        var vigentes = (await slotBloqueoService.ListarActivosAsync(cancellationToken)).Where(b => b.ExpiraEn > ahora).ToList();
        if (vigentes.Count == 0)
        {
            return [];
        }

        var barberoIds = vigentes.Select(b => b.BarberoId).Distinct().ToList();
        var clienteIds = vigentes.Select(b => b.ClienteId).Distinct().ToList();
        var barberos = await dbContext.Barberos.AsNoTracking()
            .Where(b => barberoIds.Contains(b.Id))
            .Select(b => new { b.Id, Nombre = b.Nombre + " " + b.Apellido })
            .ToDictionaryAsync(b => b.Id, b => b.Nombre.Trim(), cancellationToken);
        var clientes = await dbContext.Clientes.AsNoTracking()
            .Where(c => clienteIds.Contains(c.Id))
            .Select(c => new { c.Id, Nombre = c.Nombre + " " + c.Apellido })
            .ToDictionaryAsync(c => c.Id, c => c.Nombre.Trim(), cancellationToken);

        return vigentes
            .Where(b => barberos.ContainsKey(b.BarberoId))
            .OrderBy(b => b.ExpiraEn)
            .Select(b => new ReservaEnCursoDto
            {
                BarberoId = b.BarberoId,
                BarberoNombre = barberos[b.BarberoId],
                ClienteId = b.ClienteId,
                ClienteNombre = clientes.GetValueOrDefault(b.ClienteId, "Cliente"),
                FechaCita = b.Fecha,
                HoraInicio = b.HoraInicio,
                BloqueadoEn = b.BloqueadoEn,
                ExpiraEn = b.ExpiraEn,
                SegundosRestantes = (int)Math.Ceiling((b.ExpiraEn - ahora).TotalSeconds),
            })
            .ToList();
    }

    public async Task LiberarAsync(LiberarReservaRequest request, CancellationToken cancellationToken)
    {
        // El filtro de tenant de Barberos impide liberar horarios de otra barbería.
        var esDeEstaBarberia = await dbContext.Barberos.AsNoTracking().AnyAsync(b => b.Id == request.BarberoId, cancellationToken);
        if (!esDeEstaBarberia)
        {
            throw new NotFoundException("Ese horario ya no está apartado.");
        }

        var liberado = await slotBloqueoService.LiberarSinTokenAsync(request.BarberoId, request.FechaCita, request.HoraInicio, cancellationToken)
            ?? throw new NotFoundException("Ese horario ya no está apartado.");

        await notificationService.NotificarHorarioLiberadoClienteAsync(
            liberado.ClienteId,
            $"El horario del {Fecha(liberado.Fecha)} a las {Hora(liberado.HoraInicio)} se liberó. Puedes elegir otro en la app.",
            cancellationToken);
    }

    /// <summary>`sáb 7 nov`</summary>
    private static string Fecha(DateOnly d) => $"{Dias[(int)d.DayOfWeek]} {d.Day} {Meses[d.Month - 1]}";

    /// <summary>`2:30 p. m.` (es-CO)</summary>
    private static string Hora(TimeOnly t)
    {
        var h12 = t.Hour % 12 == 0 ? 12 : t.Hour % 12;
        return $"{h12}:{t.Minute:00} {(t.Hour < 12 ? "a. m." : "p. m.")}";
    }
}
