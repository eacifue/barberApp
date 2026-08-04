using Barberia.Application.DTOs.Servicios;
using FluentValidation;

namespace Barberia.Application.Validators.Servicios;

public class CreateServicioValidator : AbstractValidator<CreateServicioRequest>
{
    public CreateServicioValidator()
    {
        RuleFor(x => x.Nombre)
            .NotEmpty()
            .WithMessage("El nombre es obligatorio.")
            .MinimumLength(2)
            .WithMessage("El nombre debe tener al menos 2 caracteres.")
            .MaximumLength(80)
            .WithMessage("El nombre no puede superar 80 caracteres.");

        RuleFor(x => x.DuracionMinutos)
            .InclusiveBetween(10, 240)
            .WithMessage("La duración debe estar entre 10 y 240 minutos.");

        RuleFor(x => x.Precio)
            .GreaterThan(0)
            .WithMessage("El precio debe ser mayor que cero.")
            .LessThan(1_000_000)
            .WithMessage("El precio debe ser menor a 1.000.000.");
    }
}
