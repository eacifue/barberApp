using Barberia.Application.Interfaces.Services;
using Barberia.Application.Interfaces.Services.Auth;
using Barberia.Application.Interfaces.Services.Availability;
using Barberia.Application.Interfaces.Services.Barberias;
using Barberia.Application.Interfaces.Services.Barberos;
using Barberia.Application.Interfaces.Services.Citas;
using Barberia.Application.Interfaces.Services.Clientes;
using Barberia.Application.Interfaces.Services.Disponibilidad;
using Barberia.Application.Interfaces.Services.Servicios;
using Barberia.Application.Interfaces.Services.Slots;
using Barberia.Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace Barberia.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<IAppointmentService, AppointmentService>();
        services.AddScoped<IServicioService, ServicioService>();
        services.AddScoped<IBarberoService, BarberoService>();
        services.AddScoped<IBarberiaService, BarberiaService>();
        services.AddScoped<IClienteAdminService, ClienteAdminService>();
        services.AddScoped<IDisponibilidadService, DisponibilidadService>();
        services.AddSingleton(TimeProvider.System);
        services.AddScoped<ICitaService, CitaService>();
        services.AddScoped<IAvailabilityService, AvailabilityService>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IReservasEnCursoService, ReservasEnCursoService>();

        return services;
    }
}
