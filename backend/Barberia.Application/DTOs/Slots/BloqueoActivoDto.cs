namespace Barberia.Application.DTOs.Slots;

/// <summary>Horario apartado temporalmente por un cliente mientras confirma su reserva.</summary>
public sealed record BloqueoActivoDto(
    Guid BarberoId,
    DateOnly Fecha,
    TimeOnly HoraInicio,
    Guid ClienteId,
    DateTime BloqueadoEn,
    DateTime ExpiraEn);
