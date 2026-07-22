using Barberia.Application.DTOs.Appointments;
using FluentValidation;

namespace Barberia.Application.Validators.Appointments;

public class CreateAppointmentRequestValidator : AbstractValidator<CreateAppointmentRequest>
{
    public CreateAppointmentRequestValidator()
    {
        RuleFor(x => x.ResolveClienteId())
            .NotEmpty()
            .WithMessage("El identificador del cliente es obligatorio.");

        RuleFor(x => x.BarberoId)
            .NotEmpty()
            .WithMessage("El identificador del barbero es obligatorio.");

        RuleFor(x => x.ServiceName)
            .NotEmpty()
            .WithMessage("El servicio es obligatorio.")
            .MaximumLength(120)
            .WithMessage("El nombre del servicio no puede superar 120 caracteres.");

        RuleFor(x => x.ResolveStartTimeUtc())
            .NotEmpty()
            .WithMessage("La fecha de inicio es obligatoria.")
            .Must(x => x > DateTime.UtcNow)
            .WithMessage("La fecha de inicio debe ser futura.");

        RuleFor(x => x.ResolveEndTimeUtc())
            .NotEmpty()
            .WithMessage("La fecha de fin es obligatoria.")
            .Must((request, endTime) => endTime > request.ResolveStartTimeUtc())
            .WithMessage("La fecha de fin debe ser mayor a la fecha de inicio.");

        RuleFor(x => x.FullName)
            .NotEmpty()
            .WithMessage("El nombre completo es obligatorio.")
            .MaximumLength(140)
            .WithMessage("El nombre completo no puede superar 140 caracteres.");

        RuleFor(x => x.Identification)
            .NotEmpty()
            .WithMessage("La identificación es obligatoria.")
            .MaximumLength(30)
            .WithMessage("La identificación no puede superar 30 caracteres.");

        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .WithMessage("El teléfono es obligatorio.")
            .MaximumLength(30)
            .WithMessage("El teléfono no puede superar 30 caracteres.");
    }
}
