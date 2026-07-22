using Barberia.Application.DTOs.Barberias;
using FluentValidation;

namespace Barberia.Application.Validators.Barberias;

public sealed class UpsertBarberiaRequestValidator : AbstractValidator<UpsertBarberiaRequest>
{
    public UpsertBarberiaRequestValidator()
    {
        RuleFor(x => x.Nombre)
            .NotEmpty().WithMessage("El nombre es requerido.")
            .MaximumLength(140).WithMessage("El nombre no puede exceder 140 caracteres.");

        RuleFor(x => x.Telefono)
            .NotEmpty().WithMessage("El teléfono es requerido.")
            .MaximumLength(30).WithMessage("El teléfono no puede exceder 30 caracteres.");

        RuleFor(x => x.Correo)
            .NotEmpty().WithMessage("El correo es requerido.")
            .EmailAddress().WithMessage("El correo no es válido.")
            .MaximumLength(150).WithMessage("El correo no puede exceder 150 caracteres.");

        RuleFor(x => x.Direccion)
            .NotEmpty().WithMessage("La dirección es requerida.")
            .MaximumLength(250).WithMessage("La dirección no puede exceder 250 caracteres.");

        RuleFor(x => x.Ciudad)
            .NotEmpty().WithMessage("La ciudad es requerida.")
            .MaximumLength(120).WithMessage("La ciudad no puede exceder 120 caracteres.");

        RuleFor(x => x.Departamento)
            .NotEmpty().WithMessage("El departamento es requerido.")
            .MaximumLength(120).WithMessage("El departamento no puede exceder 120 caracteres.");

        RuleFor(x => x.Pais)
            .NotEmpty().WithMessage("El país es requerido.")
            .MaximumLength(100).WithMessage("El país no puede exceder 100 caracteres.");

        RuleFor(x => x.Descripcion)
            .MaximumLength(1000).WithMessage("La descripción no puede exceder 1000 caracteres.")
            .When(x => !string.IsNullOrWhiteSpace(x.Descripcion));

        RuleFor(x => x.Slogan)
            .MaximumLength(200).WithMessage("El slogan no puede exceder 200 caracteres.")
            .When(x => !string.IsNullOrWhiteSpace(x.Slogan));

        RuleFor(x => x.SitioWeb)
            .MaximumLength(200).WithMessage("El sitio web no puede exceder 200 caracteres.")
            .When(x => !string.IsNullOrWhiteSpace(x.SitioWeb));

        RuleFor(x => x.FotoPortada)
            .MaximumLength(500).WithMessage("La foto de portada no puede exceder 500 caracteres.")
            .When(x => !string.IsNullOrWhiteSpace(x.FotoPortada));

        RuleFor(x => x.HoraCierre)
            .GreaterThan(x => x.HoraApertura)
            .WithMessage("La hora de cierre debe ser mayor a la de apertura.");

        RuleFor(x => x.DiasDescanso)
            .Must(x => x is { Count: <= 7 })
            .WithMessage("Los días de descanso no pueden exceder 7 elementos.");
    }
}
