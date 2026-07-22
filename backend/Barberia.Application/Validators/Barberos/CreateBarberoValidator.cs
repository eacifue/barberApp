using Barberia.Application.DTOs.Barberos;
using FluentValidation;

namespace Barberia.Application.Validators.Barberos;

public class CreateBarberoValidator : AbstractValidator<CreateBarberoRequest>
{
    public CreateBarberoValidator()
    {
        RuleFor(x => x.Nombre)
            .NotEmpty()
            .WithMessage("El nombre es obligatorio.")
            .MinimumLength(2)
            .MaximumLength(80);

        RuleFor(x => x.Apellido)
            .NotEmpty()
            .WithMessage("El apellido es obligatorio.")
            .MinimumLength(2)
            .MaximumLength(80);

        RuleFor(x => x.Correo)
            .NotEmpty()
            .WithMessage("El correo es obligatorio.")
            .EmailAddress()
            .WithMessage("El correo no tiene un formato válido.");

        RuleFor(x => x.Telefono)
            .NotEmpty()
            .WithMessage("El teléfono es obligatorio.")
            .Matches("^[0-9]{7,15}$")
            .WithMessage("El teléfono debe contener solo dígitos y tener entre 7 y 15 caracteres.");

        RuleFor(x => x.AniosExperiencia)
            .InclusiveBetween(0, 50)
            .WithMessage("Los años de experiencia deben estar entre 0 y 50.");

        RuleFor(x => x.ServicioIds)
            .NotEmpty()
            .WithMessage("Debes asociar al menos un servicio.");
    }
}
