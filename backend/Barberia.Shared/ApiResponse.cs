namespace Barberia.Shared;

public class ApiResponse<T>
{
    public bool Success { get; init; }

    public string Message { get; init; } = string.Empty;

    public T? Data { get; init; }

    public IReadOnlyCollection<string> Errors { get; init; } = Array.Empty<string>();

    public static ApiResponse<T> Ok(T data, string message = "Operación exitosa") => new()
    {
        Success = true,
        Message = message,
        Data = data,
        Errors = Array.Empty<string>()
    };

    public static ApiResponse<T> Fail(string message, IReadOnlyCollection<string>? errors = null) => new()
    {
        Success = false,
        Message = message,
        Data = default,
        Errors = errors ?? Array.Empty<string>()
    };
}
