using Barberia.Application.DTOs.Servicios;
using Barberia.Application.Interfaces.Services.Servicios;
using Barberia.Application.Interfaces.Services;
using Barberia.Shared;
using Barberia.Shared.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Barberia.API.Controllers;

[ApiController]
public class ServiciosController : ControllerBase
{
    private readonly IServicioService servicioService;

    public ServiciosController(IServicioService servicioService)
    {
        this.servicioService = servicioService;
    }

    [HttpGet("api/v1/barberias/{barberiaId:guid}/servicios")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<List<ServicioDto>>>> GetByBarberiaAsync(
        [FromRoute] Guid barberiaId,
        CancellationToken cancellationToken)
    {
        var result = await servicioService.GetAllByBarberiaAsync(barberiaId, cancellationToken);
        return Ok(ApiResponse<List<ServicioDto>>.Ok(result, "Servicios obtenidos correctamente."));
    }

    [HttpGet("api/v1/servicios/{id:guid}", Name = "GetServicioById")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<ServicioDto>>> GetByIdAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        var result = await servicioService.GetByIdAsync(id, cancellationToken);
        return Ok(ApiResponse<ServicioDto>.Ok(result, "Servicio obtenido correctamente."));
    }

    [HttpPost("api/v1/servicios")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<ServicioDto>>> CreateAsync(
        [FromBody] CreateServicioRequest request,
        CancellationToken cancellationToken)
    {
        var result = await servicioService.CreateAsync(request, cancellationToken);
        return CreatedAtRoute("GetServicioById", new { id = result.Id }, ApiResponse<ServicioDto>.Ok(result, "Servicio creado correctamente."));
    }

    [HttpPut("api/v1/servicios/{id:guid}")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<ServicioDto>>> UpdateAsync(
        [FromRoute] Guid id,
        [FromBody] CreateServicioRequest request,
        CancellationToken cancellationToken)
    {
        var result = await servicioService.UpdateAsync(id, request, cancellationToken);
        return Ok(ApiResponse<ServicioDto>.Ok(result, "Servicio actualizado correctamente."));
    }

    [HttpDelete("api/v1/servicios/{id:guid}")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<object?>>> DeleteAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        await servicioService.DeleteAsync(id, cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, "Servicio eliminado correctamente."));
    }

    [HttpGet("api/v1/barberos/{barberoId:guid}/servicios")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<List<ServicioDto>>>> GetByBarberoAsync(
        [FromRoute] Guid barberoId,
        CancellationToken cancellationToken)
    {
        var result = await servicioService.GetByBarberoAsync(barberoId, cancellationToken);
        return Ok(ApiResponse<List<ServicioDto>>.Ok(result, "Servicios del barbero obtenidos correctamente."));
    }
}
