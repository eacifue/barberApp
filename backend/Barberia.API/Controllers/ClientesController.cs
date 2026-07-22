using Barberia.Application.DTOs.Clientes;
using Barberia.Application.Interfaces.Services.Clientes;
using Barberia.Shared;
using Barberia.Shared.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Barberia.API.Controllers;

[ApiController]
[Authorize]
public sealed class ClientesController : ControllerBase
{
    private readonly IClienteAdminService clienteAdminService;

    public ClientesController(IClienteAdminService clienteAdminService)
    {
        this.clienteAdminService = clienteAdminService;
    }

    [HttpGet("api/v1/clientes")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.AdminBarberia}")]
    public async Task<ActionResult<ApiResponse<List<ClienteDto>>>> GetAllForTenantAsync(CancellationToken cancellationToken)
    {
        var clientes = await clienteAdminService.GetAllAsync(cancellationToken);
        return Ok(ApiResponse<List<ClienteDto>>.Ok(clientes, "Clientes obtenidos correctamente."));
    }

    [HttpGet("api/v1/admin/clientes")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<List<ClienteDto>>>> GetAllAsync(CancellationToken cancellationToken)
    {
        var clientes = await clienteAdminService.GetAllAsync(cancellationToken);
        return Ok(ApiResponse<List<ClienteDto>>.Ok(clientes, "Clientes obtenidos correctamente."));
    }

    [HttpGet("api/v1/admin/clientes/{id:guid}")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<ClienteDto>>> GetByIdAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        var cliente = await clienteAdminService.GetByIdAsync(id, cancellationToken);
        return Ok(ApiResponse<ClienteDto>.Ok(cliente, "Cliente obtenido correctamente."));
    }

    [HttpPost("api/v1/admin/clientes")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<ClienteDto>>> CreateAsync(
        [FromBody] CreateClienteAdminRequest request,
        CancellationToken cancellationToken)
    {
        var cliente = await clienteAdminService.CreateAsync(request, cancellationToken);
        return Created($"/api/v1/admin/clientes/{cliente.Id}", ApiResponse<ClienteDto>.Ok(cliente, "Cliente creado correctamente."));
    }

    [HttpPut("api/v1/admin/clientes/{id:guid}")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<ClienteDto>>> UpdateAsync(
        [FromRoute] Guid id,
        [FromBody] UpdateClienteAdminRequest request,
        CancellationToken cancellationToken)
    {
        var cliente = await clienteAdminService.UpdateAsync(id, request, cancellationToken);
        return Ok(ApiResponse<ClienteDto>.Ok(cliente, "Cliente actualizado correctamente."));
    }

    [HttpDelete("api/v1/admin/clientes/{id:guid}")]
    [Authorize(Policy = Roles.Admin)]
    public async Task<ActionResult<ApiResponse<object?>>> DeleteAsync(
        [FromRoute] Guid id,
        CancellationToken cancellationToken)
    {
        await clienteAdminService.DeleteAsync(id, cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, "Cliente desactivado correctamente."));
    }
}
