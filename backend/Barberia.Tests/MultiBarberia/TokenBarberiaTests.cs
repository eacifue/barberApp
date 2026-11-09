using System.IdentityModel.Tokens.Jwt;
using Barberia.Domain.Entities;
using Barberia.Infrastructure.Services;
using Microsoft.Extensions.Configuration;

namespace Barberia.Tests.MultiBarberia;

// El token dice a qué barbería pertenece quien inicia sesión; el SuperAdmin no tiene.
public sealed class TokenBarberiaTests
{
    private static readonly IConfiguration Config = new ConfigurationBuilder()
        .AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Jwt:Key"] = "clave-de-pruebas-de-al-menos-32-caracteres!!",
            ["Jwt:Issuer"] = "barberia-tests",
            ["Jwt:Audience"] = "barberia-tests",
        })
        .Build();

    private static JwtSecurityToken TokenDe(Cliente cliente) =>
        new JwtSecurityTokenHandler().ReadJwtToken(new JwtTokenGenerator(Config).GenerateClienteToken(cliente));

    [Theory]
    [InlineData("Cliente")]
    [InlineData("AdministradorBarberia")]
    [InlineData("Barbero")]
    public void El_token_lleva_la_barberia_de_la_cuenta(string rol)
    {
        var barberiaId = Guid.NewGuid();
        var cuenta = new Cliente { BarberiaId = barberiaId, Rol = rol, Correo = "laura@correo.co", BarberoId = rol == "Barbero" ? Guid.NewGuid() : null };

        var token = TokenDe(cuenta);

        Assert.Equal(barberiaId.ToString(), token.Claims.Single(c => c.Type == "barberiaId").Value);
    }

    [Fact]
    public void El_token_del_superadmin_no_lleva_barberia()
    {
        var token = TokenDe(new Cliente { BarberiaId = null, Rol = "Admin", Correo = "admin@barberia.local" });

        Assert.DoesNotContain(token.Claims, c => c.Type == "barberiaId");
    }
}
