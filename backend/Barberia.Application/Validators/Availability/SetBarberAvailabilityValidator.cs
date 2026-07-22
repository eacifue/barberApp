using Barberia.Application.DTOs.Availability;
using FluentValidation;

namespace Barberia.Application.Validators.Availability;

public class SetBarberAvailabilityValidator : AbstractValidator<UpsertBarberAvailabilityRequest>
{
    public SetBarberAvailabilityValidator()
    {
        RuleFor(x => x.BarberId)
            .NotEmpty()
            .WithMessage("El barbero es obligatorio.");

        RuleFor(x => x.Availability)
            .NotNull()
            .Must(x => x.Count > 0)
            .WithMessage("Debes enviar al menos una configuración de disponibilidad.");

        RuleForEach(x => x.Availability).ChildRules(item =>
        {
            item.RuleFor(x => x)
                .Must(x => !x.IsActive || (x.StartTime.HasValue && x.EndTime.HasValue))
                .WithMessage("Los días activos deben tener hora de inicio y fin.");

            item.RuleFor(x => x)
                .Must(x => !x.IsActive || x.StartTime < x.EndTime)
                .WithMessage("La hora de inicio debe ser menor a la hora de fin.");
        });

        RuleFor(x => x.Availability)
            .Must(NoOverlaps)
            .WithMessage("No se permiten rangos solapados para el mismo día.");
    }

    private static bool NoOverlaps(List<BarberAvailabilityInput> items)
    {
        foreach (var group in items.Where(x => x.IsActive).GroupBy(x => x.DayOfWeek))
        {
            var ordered = group
                .Where(x => x.StartTime.HasValue && x.EndTime.HasValue)
                .OrderBy(x => x.StartTime)
                .ToList();

            for (var i = 1; i < ordered.Count; i++)
            {
                if (ordered[i - 1].EndTime > ordered[i].StartTime)
                {
                    return false;
                }
            }
        }

        return true;
    }
}
