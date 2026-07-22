namespace Barberia.Application.Interfaces.Services;

public interface ICacheService
{
    Task<bool> ExistsAsync(string key, CancellationToken cancellationToken);

    Task SetAsync(string key, string value, TimeSpan ttl, CancellationToken cancellationToken);

    /// <summary>Agrega un miembro a un Redis SET y renueva su TTL.</summary>
    Task AddToSetAsync(string setKey, string member, TimeSpan ttl, CancellationToken cancellationToken);

    /// <summary>Retorna todos los miembros del SET y luego lo elimina atómicamente.</summary>
    Task<IReadOnlyList<string>> PopSetAsync(string setKey, CancellationToken cancellationToken);

    /// <summary>Elimina una clave de Redis.</summary>
    Task DeleteAsync(string key, CancellationToken cancellationToken);
}
