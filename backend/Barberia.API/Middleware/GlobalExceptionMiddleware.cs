using System.Net;
using Barberia.Application.Exceptions;
using Barberia.Shared;
using Serilog;

namespace Barberia.API.Middleware;

public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate next;

    public GlobalExceptionMiddleware(RequestDelegate next)
    {
        this.next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            Log.Error(ex, "Se produjo una excepción no controlada en la petición {Path}", context.Request.Path);
            await HandleExceptionAsync(context, ex);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var (statusCode, message, errors) = exception switch
        {
            NotFoundException notFound => (HttpStatusCode.NotFound, notFound.Message, Array.Empty<string>()),
            ValidationException validation => (HttpStatusCode.BadRequest, validation.Message, validation.Errors),
            FluentValidation.ValidationException fluentValidation =>
                (HttpStatusCode.BadRequest, "La solicitud contiene errores de validación.", fluentValidation.Errors.Select(x => x.ErrorMessage).ToArray()),
            UnauthorizedException unauthorized => (HttpStatusCode.Unauthorized, unauthorized.Message, Array.Empty<string>()),
            ConflictException conflict => (HttpStatusCode.Conflict, conflict.Message, Array.Empty<string>()),
            _ => (HttpStatusCode.InternalServerError, "Ocurrió un error interno en el servidor.", Array.Empty<string>())
        };

        var response = ApiResponse<object?>.Fail(message, errors);

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;

        await context.Response.WriteAsJsonAsync(response);
    }
}
