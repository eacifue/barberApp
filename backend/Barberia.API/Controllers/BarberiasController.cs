using Barberia.Application.DTOs.Barberias;
using Barberia.Application.Interfaces.Services.Barberias;
using Barberia.Shared;
using Barberia.Shared.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Barberia.API.Controllers;

[ApiController]
public sealed class BarberiasController : ControllerBase
{
    private readonly IBarberiaService barberiaService;

    public BarberiasController(IBarberiaService barberiaService)
    {
        this.barberiaService = barberiaService;
    }

    [HttpGet("api/v1/barberias")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<List<BarberiaDto>>>> GetAllAsync(CancellationToken cancellationToken)
    {
        var barberias = await barberiaService.GetAllAsync(cancellationToken);
        var visibles = barberias.Where(x => x.Activo && x.Activa).ToList();
        return Ok(ApiResponse<List<BarberiaDto>>.Ok(visibles, "Barberías obtenidas correctamente."));
    }

    [HttpGet("api/v1/barberias/{id:guid}")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<BarberiaDto>>> GetByIdAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        var barberia = await barberiaService.GetByIdAsync(id, cancellationToken);
        if (!barberia.Activo || !barberia.Activa)
        {
            return NotFound(ApiResponse<BarberiaDto>.Fail("La barbería solicitada no existe."));
        }

        return Ok(ApiResponse<BarberiaDto>.Ok(barberia, "Barbería obtenida correctamente."));
    }

    [HttpGet("api/v1/admin/barberias")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<List<BarberiaDto>>>> GetAllAdminAsync(CancellationToken cancellationToken)
    {
        var barberias = await barberiaService.GetAllAsync(cancellationToken);
        return Ok(ApiResponse<List<BarberiaDto>>.Ok(barberias, "Barberías obtenidas correctamente."));
    }

    [HttpGet("api/v1/admin/barberias/{id:guid}")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<BarberiaDto>>> GetByIdAdminAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        var barberia = await barberiaService.GetByIdAsync(id, cancellationToken);
        return Ok(ApiResponse<BarberiaDto>.Ok(barberia, "Barbería obtenida correctamente."));
    }

    [HttpPut("api/v1/admin/barberias/{id:guid}")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<BarberiaDto>>> UpdateAsync(
        [FromRoute] Guid id,
        [FromBody] UpsertBarberiaRequest request,
        CancellationToken cancellationToken)
    {
        var barberia = await barberiaService.UpdateAsync(id, request, cancellationToken);
        return Ok(ApiResponse<BarberiaDto>.Ok(barberia, "Barbería actualizada correctamente."));
    }
}
