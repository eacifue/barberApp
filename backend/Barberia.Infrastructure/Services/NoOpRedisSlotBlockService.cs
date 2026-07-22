using Barberia.Application.Interfaces.Services;

namespace Barberia.Infrastructure.Services;

public class NoOpRedisSlotBlockService : IRedisSlotBlockService
{
    public Task<string?> GetValueAsync(string key, CancellationToken cancellationToken)
    {
        return Task.FromResult<string?>(null);
    }

    public Task<int?> GetRemainingMinutesAsync(string key, CancellationToken cancellationToken)
    {
        return Task.FromResult<int?>(null);
    }

    public Task DeleteAsync(string key, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}
