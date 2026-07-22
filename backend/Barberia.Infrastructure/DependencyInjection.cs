using Barberia.Application.Interfaces;
using Barberia.Application.Interfaces.Persistence;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Application.Interfaces.Services;
using Barberia.Infrastructure.Data;
using Barberia.Infrastructure.Redis;
using Barberia.Infrastructure.Repositories;
using Barberia.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using StackExchange.Redis;

namespace Barberia.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var redisConnectionString = configuration["Redis:ConnectionString"];
        if (!string.IsNullOrWhiteSpace(redisConnectionString))
        {
            services.AddSingleton<IConnectionMultiplexer>(_ => RedisConnectionFactory.Create(redisConnectionString));
            services.AddScoped<IRedisSlotBlockService, RedisSlotBlockService>();
            services.AddScoped<ISlotBloqueoService, RedisSlotBloqueoService>();
        }
        else
        {
            services.AddScoped<IRedisSlotBlockService, NoOpRedisSlotBlockService>();
            services.AddScoped<ISlotBloqueoService, NoOpSlotBloqueoService>();
        }

        services.AddScoped<IAppointmentRepository, AppointmentRepository>();
        services.AddScoped<IBarberiaDbContext>(provider => provider.GetRequiredService<BarberiaDbContext>());
        services.AddScoped<ICacheService, RedisCacheService>();
        services.AddScoped<IJwtTokenGenerator, JwtTokenGenerator>();
        services.AddScoped<INotificationService, FirebasePushNotificationService>();

        return services;
    }
}
