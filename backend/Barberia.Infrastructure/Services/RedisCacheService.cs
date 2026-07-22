using Barberia.Application.Interfaces.Services;
using Microsoft.Extensions.Caching.Distributed;
using StackExchange.Redis;

namespace Barberia.Infrastructure.Services;

public class RedisCacheService : ICacheService
{
    private readonly IDistributedCache distributedCache;
    private readonly IConnectionMultiplexer redis;

    public RedisCacheService(IDistributedCache distributedCache, IConnectionMultiplexer redis)
    {
        this.distributedCache = distributedCache;
        this.redis = redis;
    }

    public async Task<bool> ExistsAsync(string key, CancellationToken cancellationToken)
    {
        var value = await distributedCache.GetStringAsync(key, cancellationToken);
        return !string.IsNullOrWhiteSpace(value);
    }

    public Task SetAsync(string key, string value, TimeSpan ttl, CancellationToken cancellationToken)
    {
        return distributedCache.SetStringAsync(
            key,
            value,
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = ttl
            },
            cancellationToken);
    }

    public async Task AddToSetAsync(string setKey, string member, TimeSpan ttl, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var db = redis.GetDatabase();
        await db.SetAddAsync(setKey, member);
        await db.KeyExpireAsync(setKey, ttl);
    }

    public async Task<IReadOnlyList<string>> PopSetAsync(string setKey, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var db = redis.GetDatabase();
        var members = await db.SetMembersAsync(setKey);
        if (members.Length > 0)
        {
            await db.KeyDeleteAsync(setKey);
        }

        return members.Select(m => m.ToString()).ToList();
    }

    public async Task DeleteAsync(string key, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var db = redis.GetDatabase();
        await db.KeyDeleteAsync(key);
    }
}
