using Barberia.Application.DTOs.Slots;
using Barberia.Application.Interfaces;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Interfaces.Services.Disponibilidad;
using Barberia.Application.Interfaces.Services.Servicios;
using Barberia.Shared;
using Barberia.Shared.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Barberia.API.Controllers;

[ApiController]
public class SlotsController : ControllerBase
{
    private readonly ISlotBloqueoService slotBloqueoService;
    private readonly ICurrentUserService currentUserService;
    private readonly IServicioService servicioService;
    private readonly IDisponibilidadService disponibilidadService;

    public SlotsController(
        ISlotBloqueoService slotBloqueoService,
        ICurrentUserService currentUserService,
        IServicioService servicioService,
        IDisponibilidadService disponibilidadService)
    {
        this.slotBloqueoService = slotBloqueoService;
        this.currentUserService = currentUserService;
        this.servicioService = servicioService;
        this.disponibilidadService = disponibilidadService;
    }

    [HttpPost("api/v1/slots/bloquear")]
    [Authorize(Roles = $"{Roles.Cliente},{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<BloqueoResultDto>>> BloquearAsync(
        [FromBody] BloquearSlotRequest request,
        CancellationToken cancellationToken)
    {
        var colombiaZone = TimeZoneInfo.FindSystemTimeZoneById("America/Bogota");
        var nowLocal = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, colombiaZone);
        var todayLocal = DateOnly.FromDateTime(nowLocal);
        var nowTimeLocal = TimeOnly.FromDateTime(nowLocal);
        if (request.FechaCita < todayLocal
            || (request.FechaCita == todayLocal && request.HoraInicio <= nowTimeLocal))
        {
            return Conflict(ApiResponse<BloqueoResultDto>.Fail("No puedes reservar un horario pasado. Selecciona una hora futura."));
        }

        var clienteId = currentUserService.ClienteId;
        if (!currentUserService.IsCliente)
        {
            clienteId = request.ClienteId;
        }

        if (clienteId is null)
        {
            return BadRequest(ApiResponse<BloqueoResultDto>.Fail("Debes indicar un cliente válido para bloquear el slot."));
        }

        var servicios = await servicioService.GetByBarberoAsync(request.BarberoId, cancellationToken);
        if (!servicios.Any(x => x.Id == request.ServicioId))
        {
            return BadRequest(ApiResponse<BloqueoResultDto>.Fail("El servicio indicado no pertenece al barbero."));
        }

        var disponibilidad = await disponibilidadService.GetSlotsDisponiblesAsync(
            request.BarberoId,
            request.ServicioId,
            request.FechaCita,
            cancellationToken);

        var slotValido = disponibilidad.Slots.Any(slot => slot.Disponible && slot.HoraInicio == request.HoraInicio);
        if (!slotValido)
        {
            return Conflict(ApiResponse<BloqueoResultDto>.Fail("El horario seleccionado no está disponible como slot válido."));
        }

        var result = await slotBloqueoService.BloquearSlotAsync(
            request.BarberoId,
            request.FechaCita,
            request.HoraInicio,
            clienteId.Value,
            cancellationToken);

        if (!result.Exitoso)
        {
            return Conflict(ApiResponse<BloqueoResultDto>.Fail(result.MensajeError ?? "No se pudo bloquear el slot."));
        }

        return Ok(ApiResponse<BloqueoResultDto>.Ok(result, result.Mensaje));
    }

    [HttpDelete("api/v1/slots/liberar")]
    [Authorize(Policy = Roles.Cliente)]
    public async Task<ActionResult<ApiResponse<object?>>> LiberarAsync(
        [FromBody] LiberarSlotRequest request,
        CancellationToken cancellationToken)
    {
        var liberado = await slotBloqueoService.LiberarSlotAsync(
            request.BarberoId,
            request.FechaCita,
            request.HoraInicio,
            request.TokenBloqueo,
            cancellationToken);

        if (!liberado)
        {
            return Ok(ApiResponse<object?>.Fail("No se liberó el slot porque ya expiró o no pertenece al token indicado."));
        }

        return Ok(ApiResponse<object?>.Ok(null, "Slot liberado correctamente."));
    }
}
