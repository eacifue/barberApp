namespace Barberia.Application.Interfaces.Services;

public interface IRedisSlotBlockService
{
    Task<string?> GetValueAsync(string key, CancellationToken cancellationToken);

    Task<int?> GetRemainingMinutesAsync(string key, CancellationToken cancellationToken);

    Task DeleteAsync(string key, CancellationToken cancellationToken);
}
