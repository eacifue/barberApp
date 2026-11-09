using Barberia.Application.DTOs.Barberias;
using Barberia.Application.Interfaces.Services;
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
    private readonly ICurrentUserService currentUserService;

    public BarberiasController(IBarberiaService barberiaService, ICurrentUserService currentUserService)
    {
        this.barberiaService = barberiaService;
        this.currentUserService = currentUserService;
    }

    /// <summary>
    /// El administrador de una barbería solo llega a la suya; otra responde 404, como si no
    /// existiera. El SuperAdmin llega a todas.
    /// </summary>
    private bool EsAjena(Guid id) => !currentUserService.IsAdmin && currentUserService.BarberiaId != id;

    private NotFoundObjectResult NoExiste() => NotFound(ApiResponse<BarberiaDto>.Fail("La barbería no existe."));

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
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<List<BarberiaDto>>>> GetAllAdminAsync(CancellationToken cancellationToken)
    {
        var barberias = (await barberiaService.GetAllAsync(cancellationToken)).Where(x => !EsAjena(x.Id)).ToList();
        return Ok(ApiResponse<List<BarberiaDto>>.Ok(barberias, "Barberías obtenidas correctamente."));
    }

    [HttpGet("api/v1/admin/barberias/resumen")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<List<ResumenBarberiaDto>>>> ResumenAsync(CancellationToken cancellationToken) =>
        Ok(ApiResponse<List<ResumenBarberiaDto>>.Ok(await barberiaService.ResumenAsync(cancellationToken), "Resumen de barberías."));

    [HttpGet("api/v1/admin/barberias/{id:guid}")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<BarberiaDto>>> GetByIdAdminAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        if (EsAjena(id))
        {
            return NoExiste();
        }

        var barberia = await barberiaService.GetByIdAsync(id, cancellationToken);
        return Ok(ApiResponse<BarberiaDto>.Ok(barberia, "Barbería obtenida correctamente."));
    }

    [HttpPost("api/v1/admin/barberias")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<BarberiaDto>>> CrearAsync(
        [FromBody] CrearBarberiaRequest request,
        CancellationToken cancellationToken)
    {
        var barberia = await barberiaService.CrearAsync(request, cancellationToken);
        return Created($"/api/v1/admin/barberias/{barberia.Id}", ApiResponse<BarberiaDto>.Ok(barberia, "Barbería creada."));
    }

    [HttpPut("api/v1/admin/barberias/{id:guid}/desactivar")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<BarberiaDto>>> DesactivarAsync([FromRoute] Guid id, CancellationToken cancellationToken) =>
        Ok(ApiResponse<BarberiaDto>.Ok(await barberiaService.CambiarEstadoAsync(id, false, cancellationToken), "Barbería desactivada."));

    [HttpPut("api/v1/admin/barberias/{id:guid}/activar")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<BarberiaDto>>> ActivarAsync([FromRoute] Guid id, CancellationToken cancellationToken) =>
        Ok(ApiResponse<BarberiaDto>.Ok(await barberiaService.CambiarEstadoAsync(id, true, cancellationToken), "Barbería activada."));

    [HttpPut("api/v1/admin/barberias/{id:guid}")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<BarberiaDto>>> UpdateAsync(
        [FromRoute] Guid id,
        [FromBody] UpsertBarberiaRequest request,
        CancellationToken cancellationToken)
    {
        if (EsAjena(id))
        {
            return NoExiste();
        }

        // Activar y desactivar es solo del SuperAdmin (rutas /activar y /desactivar); desde
        // «Mi negocio» el administrador de la barbería no cambia ese estado.
        if (!currentUserService.IsAdmin)
        {
            request.Activa = (await barberiaService.GetByIdAsync(id, cancellationToken)).Activa;
        }

        var barberia = await barberiaService.UpdateAsync(id, request, cancellationToken);
        return Ok(ApiResponse<BarberiaDto>.Ok(barberia, "Barbería actualizada correctamente."));
    }
}
