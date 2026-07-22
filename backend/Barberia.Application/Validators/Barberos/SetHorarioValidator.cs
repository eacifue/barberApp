using Barberia.Application.DTOs.Barberos;
using FluentValidation;

namespace Barberia.Application.Validators.Barberos;

public class SetHorarioValidator : AbstractValidator<SetHorarioRequest>
{
    private static readonly int[] IntervalosPermitidos = [15, 20, 30, 45, 60];

    public SetHorarioValidator()
    {
        RuleFor(x => x.BarberoId)
            .NotEmpty()
            .WithMessage("El barbero es obligatorio.");

        RuleFor(x => x.Horarios)
            .NotEmpty()
            .WithMessage("Debes enviar al menos un horario.");

        RuleForEach(x => x.Horarios).ChildRules(horario =>
        {
            horario.RuleFor(h => h.HoraInicio)
                .LessThan(h => h.HoraFin)
                .WithMessage("La hora de inicio debe ser menor a la hora de fin.");

            horario.RuleFor(h => h.IntervaloCitas)
                .Must(i => IntervalosPermitidos.Contains(i))
                .WithMessage("El intervalo debe ser 15, 20, 30, 45 o 60 minutos.");
        });
    }
}
