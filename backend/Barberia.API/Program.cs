using System.Text;
using Barberia.API.Middleware;
using Barberia.API.Services;
using Barberia.Application;
using Barberia.Application.DTOs.Appointments;
using Barberia.Application.Interfaces.Services;
using Barberia.Application.Mappings;
using Barberia.Application.Validators.Appointments;
using Barberia.Infrastructure;
using Barberia.Infrastructure.Data;
using Barberia.Infrastructure.Data.Seeders;
using Barberia.Infrastructure.Persistence;
using Barberia.Shared.Constants;
using FirebaseAdmin;
using FluentValidation;
using Google.Apis.Auth.OAuth2;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, loggerConfig) => loggerConfig
    .ReadFrom.Configuration(context.Configuration)
    .WriteTo.Console()
    .WriteTo.File("logs/barberia-.log", rollingInterval: RollingInterval.Day));

builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Barberia API",
        Version = "v1",
        Description = "API para gestión de reservas de barbería"
    });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Ingresa el token JWT en el formato: Bearer {token}"
    });

});

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddDbContext<BarberiaDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration["Redis:ConnectionString"];
    options.InstanceName = "barberia:";
});

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        var jwtKey = builder.Configuration["Jwt:Key"]
            ?? throw new InvalidOperationException("La clave JWT no está configurada.");

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy(Roles.Admin, policy => policy.RequireRole(Roles.Admin));
    options.AddPolicy(Roles.AdminBarberia, policy => policy.RequireRole(Roles.AdminBarberia));
    options.AddPolicy(Roles.Barbero, policy => policy.RequireRole(Roles.Barbero));
    options.AddPolicy(Roles.Cliente, policy => policy.RequireRole(Roles.Cliente));
});

builder.Services.AddAutoMapper(typeof(AppointmentProfile).Assembly);
builder.Services.AddValidatorsFromAssemblyContaining<CreateAppointmentRequestValidator>();

builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterCors", policy =>
    {
        var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? Array.Empty<string>();
        policy.WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var firebaseCredentialPath = builder.Configuration["Firebase:CredentialPath"];
if (!string.IsNullOrWhiteSpace(firebaseCredentialPath))
{
    var fullCredentialPath = Path.Combine(builder.Environment.ContentRootPath, firebaseCredentialPath);
    if (File.Exists(fullCredentialPath))
    {
        var hasFirebaseApp = true;
        try
        {
            _ = FirebaseApp.DefaultInstance;
        }
        catch
        {
            hasFirebaseApp = false;
        }

        if (!hasFirebaseApp)
        {
            FirebaseApp.Create(new AppOptions
            {
                Credential = GoogleCredential.FromFile(fullCredentialPath),
                ProjectId = builder.Configuration["Firebase:ProjectId"]
            });
        }
    }
    else
    {
        Log.Warning("No se encontró el archivo de credenciales Firebase en {Path}", fullCredentialPath);
    }
}

var app = builder.Build();

app.UseSerilogRequestLogging();
app.UseMiddleware<GlobalExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Inicialización de DB: migraciones + seed (todos los entornos)
await InitializeDatabaseAsync(app);

app.UseHttpsRedirection();
app.UseCors("FlutterCors");
app.UseAuthentication();
app.UseMiddleware<TenantContextMiddleware>();
app.UseAuthorization();

app.MapControllers();

app.Run();

// ─── Helpers ──────────────────────────────────────────────────────────────────

static async Task InitializeDatabaseAsync(WebApplication app)
{
    const int maxRetries = 10;
    const int delayMs = 3000;

    using var scope = app.Services.CreateScope();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    for (int attempt = 1; attempt <= maxRetries; attempt++)
    {
        try
        {
            var appDbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var barberiaDbContext = scope.ServiceProvider.GetRequiredService<BarberiaDbContext>();

            logger.LogInformation("Aplicando migraciones de AppDbContext... (intento {Attempt}/{Max})", attempt, maxRetries);
            await appDbContext.Database.MigrateAsync();

            logger.LogInformation("Aplicando migraciones de BarberiaDbContext...");
            await barberiaDbContext.Database.MigrateAsync();

            logger.LogInformation("Ejecutando DataSeeder...");
            await DataSeeder.SeedAsync(
                barberiaDbContext,
                configuration: app.Configuration,
                isDevelopment: app.Environment.IsDevelopment(),
                logger: logger);

            logger.LogInformation("Base de datos inicializada correctamente.");
            return;
        }
        catch (Npgsql.NpgsqlException ex) when (attempt < maxRetries)
        {
            logger.LogWarning(ex, "DB no disponible aún. Reintentando en {Delay}ms... ({Attempt}/{Max})", delayMs, attempt, maxRetries);
            await Task.Delay(delayMs);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error fatal al inicializar la base de datos.");
            throw;
        }
    }
}
