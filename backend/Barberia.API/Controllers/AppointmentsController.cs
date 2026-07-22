using Barberia.Application.DTOs.Appointments;
using Barberia.Application.Interfaces.Services;
using Barberia.Shared;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace Barberia.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AppointmentsController : ControllerBase
{
    private readonly IAppointmentService appointmentService;
    private readonly ICurrentUserService currentUserService;
    private readonly ILogger<AppointmentsController> logger;

    public AppointmentsController(
        IAppointmentService appointmentService,
        ICurrentUserService currentUserService,
        ILogger<AppointmentsController> logger)
    {
        this.appointmentService = appointmentService;
        this.currentUserService = currentUserService;
        this.logger = logger;
    }

    [HttpPost]
    [Authorize(Policy = "Cliente")]
    public async Task<ActionResult<ApiResponse<AppointmentResponse>>> CreateAsync(
        [FromBody] CreateAppointmentRequest request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            var errors = string.Join(" | ", ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage));
            logger.LogWarning("Modelo inválido al crear cita: {ModelErrors}", errors);
            return BadRequest(ApiResponse<AppointmentResponse>.Fail("El payload enviado no es válido."));
        }

        if (currentUserService.IsCliente && currentUserService.ClienteId is not null)
        {
            request.ClienteId = currentUserService.ClienteId.Value;
        }

        logger.LogInformation("Solicitud de creación de cita recibida para cliente {ClienteId}", request.ResolveClienteId());
        var result = await appointmentService.CreateAsync(request, cancellationToken);
        return CreatedAtRoute(
            routeName: "GetAppointmentById",
            routeValues: new { appointmentId = result.Id },
            value: ApiResponse<AppointmentResponse>.Ok(result, "Cita creada correctamente."));
    }

    [HttpGet]
    [Authorize(Policy = "Cliente")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<AppointmentResponse>>>> GetMyAppointmentsAsync(
        [FromQuery] Guid? userId,
        CancellationToken cancellationToken)
    {
        var clienteId = currentUserService.ClienteId ?? userId;
        if (clienteId is null || clienteId == Guid.Empty)
        {
            return Unauthorized(ApiResponse<IReadOnlyList<AppointmentResponse>>.Fail("No se pudo identificar el usuario autenticado."));
        }

        var result = await appointmentService.GetByClienteAsync(clienteId.Value, cancellationToken);
        return Ok(ApiResponse<IReadOnlyList<AppointmentResponse>>.Ok(result, "Citas obtenidas correctamente."));
    }

    [HttpGet("{appointmentId:guid}", Name = "GetAppointmentById")]
    [Authorize(Policy = "Admin")]
    public async Task<ActionResult<ApiResponse<AppointmentResponse>>> GetByIdAsync(
        [FromRoute] Guid appointmentId,
        CancellationToken cancellationToken)
    {
        logger.LogDebug("Solicitud de consulta de cita por id {AppointmentId}", appointmentId);
        var result = await appointmentService.GetByIdAsync(appointmentId, cancellationToken);
        return Ok(ApiResponse<AppointmentResponse>.Ok(result, "Cita obtenida correctamente."));
    }
}
