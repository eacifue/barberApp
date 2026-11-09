namespace Barberia.Application.Interfaces.Services.Barberias;

/// <summary>
/// Barbería en la que se crea lo que el usuario está creando (servicios,
/// barberos, clientes). Los servicios la piden aquí y nunca la toman del cuerpo
/// de la petición.
/// </summary>
public interface IBarberiaContexto
{
    Task<Guid> ObtenerIdAsync(CancellationToken cancellationToken);
}
