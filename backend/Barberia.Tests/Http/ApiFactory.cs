using System.Net.Http.Headers;
using Barberia.Application.Interfaces.Services;
using Barberia.Domain.Entities;
using Barberia.Infrastructure.Data;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Testcontainers.PostgreSql;

namespace Barberia.Tests.Http;

/// <summary>
/// El API real (pipeline, autenticación, middleware, filtros) contra un Postgres 17
/// en Testcontainers. Ambiente "Testing": ningún atajo de Development aplica.
/// Redis queda en NoOp para no depender del Redis local.
/// </summary>
public sealed class ApiFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    private readonly PostgreSqlContainer postgres = new PostgreSqlBuilder("postgres:17-alpine").Build();

    public async Task InitializeAsync()
    {
        await postgres.StartAsync();
        _ = Server; // arranca el API: migra y siembra antes de la primera prueba
    }

    public new async Task DisposeAsync()
    {
        await base.DisposeAsync();
        await postgres.DisposeAsync();
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.UseSetting("ConnectionStrings:DefaultConnection", postgres.GetConnectionString());
        builder.UseSetting("Redis:ConnectionString", string.Empty);
        builder.UseSetting("Firebase:CredentialPath", string.Empty);
        builder.UseSetting("Smtp:Host", string.Empty);
        builder.ConfigureTestServices(services => services.AddSingleton<ICacheService, CacheEnMemoria>());
    }

    /// <summary>Contexto sin usuario: sirve para sembrar y, con IgnoreQueryFilters, para verificar.</summary>
    public async Task<T> ConBaseAsync<T>(Func<BarberiaDbContext, Task<T>> accion)
    {
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<BarberiaDbContext>();
        return await accion(db);
    }

    public string TokenDe(Cliente cuenta)
    {
        using var scope = Services.CreateScope();
        return scope.ServiceProvider.GetRequiredService<IJwtTokenGenerator>().GenerateClienteToken(cuenta);
    }

    /// <summary>Cliente HTTP con la sesión de esa cuenta.</summary>
    public HttpClient ComoUsuario(Cliente cuenta)
    {
        var http = CreateClient();
        http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", TokenDe(cuenta));
        return http;
    }
}
