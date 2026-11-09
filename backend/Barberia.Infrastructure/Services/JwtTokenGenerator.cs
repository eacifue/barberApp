using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Barberia.Application.Interfaces.Services;
using Barberia.Domain.Entities;
using Barberia.Shared.Constants;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace Barberia.Infrastructure.Services;

public class JwtTokenGenerator : IJwtTokenGenerator
{
    private readonly IConfiguration configuration;

    public JwtTokenGenerator(IConfiguration configuration)
    {
        this.configuration = configuration;
    }

    public string GenerateClienteToken(Cliente cliente)
    {
        var key = configuration["Jwt:Key"] ?? throw new InvalidOperationException("La clave JWT no está configurada.");
        var issuer = configuration["Jwt:Issuer"];
        var audience = configuration["Jwt:Audience"];
        var expirationMinutes = int.TryParse(configuration["Jwt:ExpirationMinutes"], out var parsedExpirationMinutes)
            ? parsedExpirationMinutes
            : 1440;

        var rol = NormalizeRole(cliente.Rol);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, cliente.Id.ToString()),
            new(JwtRegisteredClaimNames.Email, cliente.Correo),
            new(ClaimTypes.Role, rol),
            new("clienteId", cliente.Id.ToString())
        };

        if (cliente.BarberoId.HasValue)
        {
            claims.Add(new Claim("barberoId", cliente.BarberoId.Value.ToString()));
        }

        if (cliente.BarberiaId.HasValue)
        {
            claims.Add(new Claim("barberiaId", cliente.BarberiaId.Value.ToString()));
        }

        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expirationMinutes),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static string NormalizeRole(string? role)
    {
        return role switch
        {
            Roles.Admin => Roles.Admin,
            Roles.AdminBarberia => Roles.AdminBarberia,
            Roles.Barbero => Roles.Barbero,
            _ => Roles.Cliente
        };
    }
}
