using Barberia.Application.DTOs.Citas;
using FluentValidation;

namespace Barberia.Application.Validators.Citas;

public class CreateCitaValidator : AbstractValidator<CreateCitaRequest>
{
    public CreateCitaValidator()
    {
        RuleFor(x => x.ClienteId)
            .NotEmpty()
            .WithMessage("El cliente es obligatorio.");

        RuleFor(x => x.BarberoId)
            .NotEmpty()
            .WithMessage("El barbero es obligatorio.");

        RuleFor(x => x.ServicioId)
            .NotEmpty()
            .WithMessage("El servicio es obligatorio.");

        RuleFor(x => x.FechaCita)
            .Must(x => x >= DateOnly.FromDateTime(DateTime.UtcNow))
            .WithMessage("La fecha de la cita debe ser hoy o futura.");

        RuleFor(x => x.HoraInicio)
            .NotEmpty()
            .WithMessage("La hora de inicio es obligatoria.");

        RuleFor(x => x.TokenRedisBloqueo)
            .NotEmpty()
            .WithMessage("El token de bloqueo es obligatorio.")
            .Matches("^[A-Za-z0-9:_-]{8,200}$")
            .WithMessage("El token de bloqueo no tiene un formato válido.");
    }
}
