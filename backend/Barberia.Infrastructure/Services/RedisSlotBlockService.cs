using Barberia.Application.Interfaces.Services;
using StackExchange.Redis;

namespace Barberia.Infrastructure.Services;

public class RedisSlotBlockService : IRedisSlotBlockService
{
    private readonly IConnectionMultiplexer redis;

    public RedisSlotBlockService(IConnectionMultiplexer redis)
    {
        this.redis = redis;
    }

    public async Task<string?> GetValueAsync(string key, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        var db = redis.GetDatabase();
        return await db.StringGetAsync(key);
    }

    public async Task<int?> GetRemainingMinutesAsync(string key, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        var db = redis.GetDatabase();
        var ttl = await db.KeyTimeToLiveAsync(key);

        if (!ttl.HasValue || ttl.Value <= TimeSpan.Zero)
        {
            return null;
        }

        return Math.Max(1, (int)Math.Ceiling(ttl.Value.TotalMinutes));
    }

    public async Task DeleteAsync(string key, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        var db = redis.GetDatabase();
        _ = await db.KeyDeleteAsync(key);
    }
}
