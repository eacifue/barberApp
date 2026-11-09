using System.Collections.Concurrent;
using Barberia.Application.Interfaces.Services;

namespace Barberia.Tests.Http;

/// <summary>Reemplaza a Redis en las pruebas HTTP (los TTL no se simulan).</summary>
public sealed class CacheEnMemoria : ICacheService
{
    private readonly ConcurrentDictionary<string, string> valores = new();
    private readonly ConcurrentDictionary<string, ConcurrentDictionary<string, byte>> conjuntos = new();

    public Task<bool> ExistsAsync(string key, CancellationToken cancellationToken) =>
        Task.FromResult(valores.ContainsKey(key) || conjuntos.ContainsKey(key));

    public Task SetAsync(string key, string value, TimeSpan ttl, CancellationToken cancellationToken)
    {
        valores[key] = value;
        return Task.CompletedTask;
    }

    public Task AddToSetAsync(string setKey, string member, TimeSpan ttl, CancellationToken cancellationToken)
    {
        conjuntos.GetOrAdd(setKey, _ => new())[member] = 0;
        return Task.CompletedTask;
    }

    public Task<IReadOnlyList<string>> PopSetAsync(string setKey, CancellationToken cancellationToken) =>
        Task.FromResult<IReadOnlyList<string>>(conjuntos.TryRemove(setKey, out var set) ? set.Keys.ToList() : []);

    public Task DeleteAsync(string key, CancellationToken cancellationToken)
    {
        valores.TryRemove(key, out _);
        conjuntos.TryRemove(key, out _);
        return Task.CompletedTask;
    }
}
