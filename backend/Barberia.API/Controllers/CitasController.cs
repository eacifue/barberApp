using Barberia.Application.DTOs.Citas;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Interfaces.Services.Citas;
using Barberia.Shared;
using Barberia.Shared.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Barberia.API.Controllers;

[ApiController]
public class CitasController : ControllerBase
{
    private readonly ICitaService citaService;
    private readonly ICurrentUserService currentUserService;

    public CitasController(ICitaService citaService, ICurrentUserService currentUserService)
    {
        this.citaService = citaService;
        this.currentUserService = currentUserService;
    }

    [HttpPost("api/v1/citas")]
    [Authorize(Roles = $"{Roles.Cliente},{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<CitaDto>>> CrearAsync(
        [FromBody] CreateCitaRequest request,
        CancellationToken cancellationToken)
    {
        if (currentUserService.IsCliente)
        {
            request.ClienteId = currentUserService.ClienteId ?? request.ClienteId;
        }
        var result = await citaService.CrearCitaAsync(request, cancellationToken);
        return Created($"/api/v1/citas/{result.Id}", ApiResponse<CitaDto>.Ok(result, "Cita creada correctamente."));
    }

    [HttpGet("api/v1/citas/mis-citas")]
    [Authorize(Policy = Roles.Cliente)]
    public async Task<ActionResult<ApiResponse<List<CitaDto>>>> GetMisCitasAsync(CancellationToken cancellationToken)
    {
        if (currentUserService.ClienteId is null)
        {
            return Unauthorized(ApiResponse<List<CitaDto>>.Fail("No se pudo identificar al cliente autenticado."));
        }

        var result = await citaService.GetByClienteAsync(currentUserService.ClienteId.Value, cancellationToken);
        return Ok(ApiResponse<List<CitaDto>>.Ok(result, "Citas obtenidas correctamente."));
    }

    [HttpGet("api/v1/citas/{id:guid}")]
    [Authorize]
    public async Task<ActionResult<ApiResponse<CitaDto>>> GetByIdAsync([FromRoute] Guid id, CancellationToken cancellationToken)
    {
        var result = await citaService.GetByIdAsync(id, cancellationToken);
        return Ok(ApiResponse<CitaDto>.Ok(result, "Cita obtenida correctamente."));
    }

    [HttpPut("api/v1/citas/{id:guid}/cancelar")]
    [Authorize]
    public async Task<ActionResult<ApiResponse<CitaDto>>> CancelarAsync(
        [FromRoute] Guid id,
        [FromBody] CancelarCitaRequest request,
        CancellationToken cancellationToken)
    {
        request.CitaId = id;
        var result = await citaService.CancelarCitaAsync(request, cancellationToken);
        return Ok(ApiResponse<CitaDto>.Ok(result, "Cita cancelada correctamente."));
    }

    [HttpPut("api/v1/citas/{id:guid}/confirmar")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<CitaDto>>> ConfirmarAsync([FromRoute] Guid id, CancellationToken cancellationToken)
    {
        var result = await citaService.ConfirmarCitaAsync(id, cancellationToken);
        return Ok(ApiResponse<CitaDto>.Ok(result, "Cita confirmada correctamente."));
    }

    [HttpPut("api/v1/citas/{id:guid}/completar")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<CitaDto>>> CompletarAsync([FromRoute] Guid id, CancellationToken cancellationToken)
    {
        var result = await citaService.CompletarCitaAsync(id, cancellationToken);
        return Ok(ApiResponse<CitaDto>.Ok(result, "Cita completada correctamente."));
    }

    [HttpGet("api/v1/barberos/{id:guid}/citas")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia},{Roles.Barbero}")]
    public async Task<ActionResult<ApiResponse<List<CitaDto>>>> GetByBarberoAsync(
        [FromRoute] Guid id,
        [FromQuery] DateOnly fecha,
        CancellationToken cancellationToken)
    {
        // Barbero solo puede ver sus propias citas
        if (currentUserService.IsBarbero)
        {
            if (currentUserService.BarberoId is null || currentUserService.BarberoId.Value != id)
                return Forbid();
        }

        var result = await citaService.GetByBarberoAsync(id, fecha, cancellationToken);
        return Ok(ApiResponse<List<CitaDto>>.Ok(result, "Citas del barbero obtenidas correctamente."));
    }

    /// <summary>
    /// Panel admin: lista de citas con filtro opcional por barberoId + rango de fechas.
    /// Admin y AdminBarberia ven todas; Barbero solo las suyas.
    /// </summary>
    [HttpGet("api/v1/admin/citas")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia},{Roles.Barbero}")]
    public async Task<ActionResult<ApiResponse<List<CitaDto>>>> GetAdminCitasAsync(
        [FromQuery] Guid? barberoId,
        [FromQuery] DateOnly? date,
        [FromQuery] DateOnly? from,
        [FromQuery] DateOnly? to,
        [FromQuery] DateOnly? fechaInicio,
        [FromQuery] DateOnly? fechaFin,
        [FromQuery] string? status,
        [FromQuery] int? page,
        [FromQuery] int? pageSize,
        CancellationToken cancellationToken)
    {
        var normalizedPage = page.GetValueOrDefault(1);
        if (normalizedPage < 1) normalizedPage = 1;

        var normalizedPageSize = pageSize.GetValueOrDefault(50);
        normalizedPageSize = Math.Clamp(normalizedPageSize, 1, 200);

        var normalizedStart = date ?? from ?? fechaInicio;
        var normalizedEnd = date ?? to ?? fechaFin;

        if (normalizedStart.HasValue && normalizedEnd.HasValue && normalizedStart > normalizedEnd)
        {
            return BadRequest(ApiResponse<List<CitaDto>>.Fail("El rango de fechas no es válido."));
        }

        // Barbero: forzar a su propio id
        if (currentUserService.IsBarbero)
        {
            if (currentUserService.BarberoId is null) return Forbid();
            barberoId = currentUserService.BarberoId.Value;
        }

        var result = await citaService.GetAdminListAsync(
            barberoId,
            normalizedStart,
            normalizedEnd,
            status,
            normalizedPage,
            normalizedPageSize,
            cancellationToken);

        return Ok(ApiResponse<List<CitaDto>>.Ok(result, "Citas obtenidas correctamente."));
    }
}
