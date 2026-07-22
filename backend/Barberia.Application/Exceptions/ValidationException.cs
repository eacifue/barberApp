namespace Barberia.Application.Exceptions;

public class ValidationException : Exception
{
    public ValidationException(string message) : base(message)
    {
    }

    public ValidationException(string message, IReadOnlyCollection<string> errors) : base(message)
    {
        Errors = errors;
    }

    public IReadOnlyCollection<string> Errors { get; } = Array.Empty<string>();
}
