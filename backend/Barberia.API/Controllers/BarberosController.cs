using Barberia.Application.DTOs.Barberos;
using Barberia.Application.DTOs.Availability;
using Barberia.Application.DTOs.Disponibilidad;
using Barberia.Application.Interfaces.Services.Availability;
using Barberia.Application.Interfaces.Services.Disponibilidad;
using Barberia.Application.Interfaces.Services.Servicios;
using Barberia.Application.Interfaces.Services.Barberos;
using Barberia.Application.Interfaces.Services;
using Barberia.Shared;
using Barberia.Shared.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Barberia.API.Controllers;

[ApiController]
public class BarberosController : ControllerBase
{
    private readonly IBarberoService barberoService;
    private readonly IAvailabilityService availabilityService;
    private readonly IDisponibilidadService disponibilidadService;
    private readonly IServicioService servicioService;

    public BarberosController(
        IBarberoService barberoService,
        IAvailabilityService availabilityService,
        IDisponibilidadService disponibilidadService,
        IServicioService servicioService)
    {
        this.barberoService = barberoService;
        this.availabilityService = availabilityService;
        this.disponibilidadService = disponibilidadService;
        this.servicioService = servicioService;
    }

    [HttpGet("api/v1/barberias/{barberiaId:guid}/barberos")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<List<BarberoDto>>>> GetByBarberiaAsync(
        [FromRoute] Guid barberiaId,
        CancellationToken cancellationToken,
        [FromQuery] bool incluirInactivos = false)
    {
        // Ver los desactivados es solo para el panel (Admin y Admin Barbería).
        var verInactivos = incluirInactivos && (User.IsInRole(Roles.Admin) || User.IsInRole(Roles.AdminBarberia));
        var result = await barberoService.GetAllByBarberiaAsync(barberiaId, cancellationToken, verInactivos);
        return Ok(ApiResponse<List<BarberoDto>>.Ok(result, "Barberos obtenidos correctamente."));
    }

    [HttpGet("api/v1/barberos/{id:guid}")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<BarberoDto>>> GetByIdAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        var result = await barberoService.GetByIdAsync(id, cancellationToken);
        return Ok(ApiResponse<BarberoDto>.Ok(result, "Barbero obtenido correctamente."));
    }

    [HttpGet("api/v1/servicios/{servicioId:guid}/barberos")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<List<BarberoDto>>>> GetByServicioAsync(
        [FromRoute] Guid servicioId,
        CancellationToken cancellationToken)
    {
        var result = await barberoService.GetByServicioAsync(servicioId, cancellationToken);
        return Ok(ApiResponse<List<BarberoDto>>.Ok(result, "Barberos del servicio obtenidos correctamente."));
    }

    [HttpPost("api/v1/barberos")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<BarberoDto>>> CreateAsync(
        [FromBody] CreateBarberoRequest request,
        CancellationToken cancellationToken)
    {
        var result = await barberoService.CreateAsync(request, cancellationToken);
        return Created($"/api/v1/barberos/{result.Id}", ApiResponse<BarberoDto>.Ok(result, "Barbero creado correctamente."));
    }

    [HttpPut("api/v1/barberos/{id:guid}")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<BarberoDto>>> UpdateAsync(
        [FromRoute] Guid id,
        [FromBody] CreateBarberoRequest request,
        CancellationToken cancellationToken)
    {
        var result = await barberoService.UpdateAsync(id, request, cancellationToken);
        return Ok(ApiResponse<BarberoDto>.Ok(result, "Barbero actualizado correctamente."));
    }

    [HttpDelete("api/v1/barberos/{id:guid}")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<object?>>> DeleteAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        await barberoService.DeleteAsync(id, cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, "Barbero eliminado correctamente."));
    }

    /// <summary>Reactiva un barbero (activo y disponible). Sus servicios se confirman al editarlo.</summary>
    [HttpPut("api/v1/barberos/{id:guid}/activar")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<BarberoDto>>> ActivarAsync([FromRoute] Guid id, CancellationToken cancellationToken)
    {
        var result = await barberoService.ActivarAsync(id, cancellationToken);
        return Ok(ApiResponse<BarberoDto>.Ok(result, "Barbero activado. Confirma los servicios que presta."));
    }

    [HttpPost("api/v1/barberos/{id:guid}/horarios")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<List<HorarioSemanaDto>>>> SetHorariosAsync(
        [FromRoute] Guid id,
        [FromBody] SetHorarioRequest request,
        CancellationToken cancellationToken)
    {
        request.BarberoId = id;
        var result = await barberoService.SetHorariosAsync(request, cancellationToken);
        return Ok(ApiResponse<List<HorarioSemanaDto>>.Ok(result, "Horarios actualizados correctamente."));
    }

    [HttpGet("api/v1/barberos/{id:guid}/horarios")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<List<HorarioSemanaDto>>>> GetHorariosAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        var result = await barberoService.GetHorariosAsync(id, cancellationToken);
        return Ok(ApiResponse<List<HorarioSemanaDto>>.Ok(result, "Horarios obtenidos correctamente."));
    }

    [HttpPut("api/v1/barberos/{id:guid}/fcm-token")]
    [Authorize]
    public async Task<ActionResult<ApiResponse<object?>>> UpdateTokenFcmAsync(
        [FromRoute] Guid id,
        [FromBody] UpdateBarberoFcmTokenRequest request,
        CancellationToken cancellationToken)
    {
        await barberoService.UpdateTokenFCMAsync(id, request.Token, cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, "Token FCM actualizado correctamente."));
    }

    [HttpPost("api/v1/barbers/{id:guid}/availability")]
    [HttpPost("api/barbers/{id:guid}/availability")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<List<BarberAvailabilityDto>>>> SetAvailabilityAsync(
        [FromRoute] Guid id,
        [FromBody] UpsertBarberAvailabilityRequest request,
        CancellationToken cancellationToken)
    {
        request.BarberId = id;
        var result = await availabilityService.SetAvailabilityAsync(request, cancellationToken);
        return Ok(ApiResponse<List<BarberAvailabilityDto>>.Ok(result, "Disponibilidad configurada correctamente."));
    }

    [HttpGet("api/v1/barbers/{id:guid}/availability")]
    [HttpGet("api/barbers/{id:guid}/availability")]
    [Authorize]
    public async Task<ActionResult<ApiResponse<List<BarberAvailabilityDto>>>> GetAvailabilityAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        var result = await availabilityService.GetAvailabilityAsync(id, cancellationToken);
        return Ok(ApiResponse<List<BarberAvailabilityDto>>.Ok(result, "Disponibilidad obtenida correctamente."));
    }

    [HttpPost("api/v1/barbers/{id:guid}/day-off")]
    [HttpPost("api/barbers/{id:guid}/day-off")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<BarberDayOffDto>>> AddDayOffAsync(
        [FromRoute] Guid id,
        [FromBody] CreateBarberDayOffRequest request,
        CancellationToken cancellationToken)
    {
        request.BarberId = id;
        var result = await availabilityService.AddDayOffAsync(request, cancellationToken);
        return Ok(ApiResponse<BarberDayOffDto>.Ok(result, "Día no disponible agregado correctamente."));
    }

    /// <summary>Días libres de hoy en adelante.</summary>
    [HttpGet("api/v1/barbers/{id:guid}/day-off")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<List<BarberDayOffDto>>>> GetDaysOffAsync([FromRoute] Guid id, CancellationToken cancellationToken)
    {
        var result = await availabilityService.GetDaysOffAsync(id, cancellationToken);
        return Ok(ApiResponse<List<BarberDayOffDto>>.Ok(result, "Días libres obtenidos correctamente."));
    }

    [HttpDelete("api/v1/barbers/{id:guid}/day-off/{dayOffId:guid}")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<object?>>> RemoveDayOffAsync([FromRoute] Guid id, [FromRoute] Guid dayOffId, CancellationToken cancellationToken)
    {
        await availabilityService.RemoveDayOffAsync(id, dayOffId, cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, "Día libre quitado."));
    }

    [HttpGet("api/v1/barbers/{id:guid}/slots")]
    [HttpGet("api/barbers/{id:guid}/slots")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<List<BarberSlotDto>>>> GetSlotsByDateAsync(
        [FromRoute] Guid id,
        [FromQuery] DateOnly date,
        CancellationToken cancellationToken)
    {
        var result = await availabilityService.GetAvailableSlotsAsync(id, date, cancellationToken);
        return Ok(ApiResponse<List<BarberSlotDto>>.Ok(result, "Slots disponibles obtenidos correctamente."));
    }

    [HttpGet("api/v1/barberos/{barberoId:guid}/disponibilidad")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<DisponibilidadBarberoDto>>> GetDisponibilidadAsync(
        [FromRoute] Guid barberoId,
        [FromQuery] Guid servicioId,
        [FromQuery] DateOnly fecha,
        CancellationToken cancellationToken)
    {
        var hoy = DateOnly.FromDateTime(DateTime.UtcNow);
        if (fecha < hoy)
        {
            return BadRequest(ApiResponse<DisponibilidadBarberoDto>.Fail("La fecha no puede ser pasada."));
        }

        if (fecha > hoy.AddDays(30))
        {
            return BadRequest(ApiResponse<DisponibilidadBarberoDto>.Fail("La fecha no puede ser mayor a 30 días en el futuro."));
        }

        var serviciosBarbero = await servicioService.GetByBarberoAsync(barberoId, cancellationToken);
        var servicioPertenece = serviciosBarbero.Any(x => x.Id == servicioId);

        if (!servicioPertenece)
        {
            return BadRequest(ApiResponse<DisponibilidadBarberoDto>.Fail("El servicio indicado no pertenece al barbero."));
        }

        var result = await disponibilidadService.GetSlotsDisponiblesAsync(barberoId, servicioId, fecha, cancellationToken);
        return Ok(ApiResponse<DisponibilidadBarberoDto>.Ok(result, "Disponibilidad obtenida correctamente."));
    }
}
