using System;
using System.Threading.Tasks;
using Barberia.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

class Program
{
    static async Task Main(string[] args)
    {
        var config = new ConfigurationBuilder()
            .AddJsonFile("Barberia.API/appsettings.json", optional: false)
            .AddJsonFile("Barberia.API/appsettings.Development.json", optional: true)
            .Build();

        var services = new ServiceCollection();
        
        services.AddDbContext<BarberiaDbContext>(options =>
            options.UseNpgsql(config.GetConnectionString("DefaultConnection")));

        var serviceProvider = services.BuildServiceProvider();
        
        using var scope = serviceProvider.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<BarberiaDbContext>();

        Console.WriteLine("╔═══════════════════════════════════════════════════════════════════════════════╗");
        Console.WriteLine("║                        USUARIOS REGISTRADOS EN LA BD                          ║");
        Console.WriteLine("╚═══════════════════════════════════════════════════════════════════════════════╝\n");

        var clientes = await dbContext.Clientes.OrderByDescending(c => c.CreatedAt).ToListAsync();
        
        if (!clientes.Any())
        {
            Console.WriteLine("❌ No hay usuarios registrados en la base de datos.\n");
            return;
        }

        Console.WriteLine($"Total de usuarios: {clientes.Count}\n");
        Console.WriteLine("┌─────┬─────────────────────┬────────────────────────┬──────────────────────────┬──────────┬─────────────────────┐");
        Console.WriteLine("│ ID  │ Nombre              │ Apellido               │ Correo                   │ Rol      │ Fecha de Creación   │");
        Console.WriteLine("├─────┼─────────────────────┼────────────────────────┼──────────────────────────┼──────────┼─────────────────────┤");

        foreach (var cliente in clientes)
        {
            var id = cliente.Id.ToString().Substring(0, 8);
            var nombre = cliente.Nombre.PadRight(19);
            var apellido = cliente.Apellido.PadRight(22);
            var correo = cliente.Correo.PadRight(24);
            var rol = cliente.Rol.PadRight(8);
            var fecha = cliente.CreatedAt.ToString("yyyy-MM-dd HH:mm");

            Console.WriteLine($"│ {id} │ {nombre} │ {apellido} │ {correo} │ {rol} │ {fecha} │");
        }

        Console.WriteLine("└─────┴─────────────────────┴────────────────────────┴──────────────────────────┴──────────┴─────────────────────┘\n");
        
        // Estadísticas por rol
        Console.WriteLine("\n📊 Estadísticas por Rol:");
        Console.WriteLine("┌──────────────────┬─────────┐");
        var porRol = clientes.GroupBy(c => c.Rol).OrderByDescending(g => g.Count());
        foreach (var grupo in porRol)
        {
            Console.WriteLine($"│ {grupo.Key.PadRight(16)} │ {grupo.Count().ToString().PadLeft(5)} │");
        }
        Console.WriteLine("└──────────────────┴─────────┘");
    }
}
