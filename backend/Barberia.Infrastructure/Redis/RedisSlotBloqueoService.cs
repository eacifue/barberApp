using System.Text.Json;
using Barberia.Application.DTOs.Slots;
using Barberia.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using StackExchange.Redis;

namespace Barberia.Infrastructure.Redis;

public class RedisSlotBloqueoService : ISlotBloqueoService
{
    private const string KeyPrefix = "barberia:slot:";
    private readonly IConnectionMultiplexer redis;
    private readonly int ttlSeconds;

    public RedisSlotBloqueoService(IConnectionMultiplexer redis, IConfiguration configuration)
    {
        this.redis = redis;
        ttlSeconds = (int.TryParse(configuration["Redis:BlockTtlMinutes"], out var ttlMinutes) ? ttlMinutes : 5) * 60;
    }

    public async Task<BloqueoResultDto> BloquearSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, Guid clienteId, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        var db = redis.GetDatabase();
        var key = BuildKey(barberoId, fecha, horaInicio);
        var existingValue = await db.StringGetAsync(key);

        if (existingValue.HasValue)
        {
            var existingLock = Deserialize(existingValue!);
            if (existingLock is not null)
            {
                if (existingLock.ClienteId != clienteId)
                {
                    return new BloqueoResultDto
                    {
                        Exitoso = false,
                        MensajeError = "Slot reservado temporalmente",
                        Mensaje = "El horario ya está reservado temporalmente por otro cliente.",
                        ExpiresInSeconds = Math.Max(1, (int)Math.Ceiling((existingLock.ExpiraEn - DateTime.UtcNow).TotalSeconds))
                    };
                }

                existingLock.BloqueadoEn = DateTime.UtcNow;
                existingLock.ExpiraEn = DateTime.UtcNow.AddSeconds(ttlSeconds);
                var renewedJson = JsonSerializer.Serialize(existingLock);
                _ = await db.StringSetAsync(key, renewedJson, TimeSpan.FromSeconds(ttlSeconds));

                return new BloqueoResultDto
                {
                    Exitoso = true,
                    TokenBloqueo = existingLock.TokenBloqueo,
                    ExpiresInSeconds = ttlSeconds,
                    Mensaje = "Horario reservado por 5 minutos. Completa tu reserva."
                };
            }
        }

        var payload = new SlotBloqueoRedisModel
        {
            ClienteId = clienteId,
            TokenBloqueo = Guid.NewGuid().ToString(),
            BloqueadoEn = DateTime.UtcNow,
            ExpiraEn = DateTime.UtcNow.AddSeconds(ttlSeconds)
        };

        var json = JsonSerializer.Serialize(payload);
        var wasSet = await db.StringSetAsync(key, json, TimeSpan.FromSeconds(ttlSeconds), when: When.NotExists);
        if (!wasSet)
        {
            return new BloqueoResultDto
            {
                Exitoso = false,
                MensajeError = "Slot reservado temporalmente",
                Mensaje = "El horario ya fue tomado por otro cliente.",
                ExpiresInSeconds = ttlSeconds
            };
        }

        return new BloqueoResultDto
        {
            Exitoso = true,
            TokenBloqueo = payload.TokenBloqueo,
            ExpiresInSeconds = ttlSeconds,
            Mensaje = "Horario reservado por 5 minutos. Completa tu reserva."
        };
    }

    public async Task<bool> LiberarSlotAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, string tokenBloqueo, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        var db = redis.GetDatabase();
        var key = BuildKey(barberoId, fecha, horaInicio);
        var value = await db.StringGetAsync(key);

        if (!value.HasValue)
        {
            return false;
        }

        var existingLock = Deserialize(value!);
        if (existingLock is null || !string.Equals(existingLock.TokenBloqueo, tokenBloqueo, StringComparison.Ordinal))
        {
            return false;
        }

        return await db.KeyDeleteAsync(key);
    }

    public async Task<BloqueoInfoDto?> ConsultarBloqueoAsync(Guid barberoId, DateOnly fecha, TimeOnly horaInicio, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        var db = redis.GetDatabase();
        var key = BuildKey(barberoId, fecha, horaInicio);
        var value = await db.StringGetAsync(key);
        if (!value.HasValue)
        {
            return null;
        }

        var existingLock = Deserialize(value!);
        if (existingLock is null)
        {
            return null;
        }

        var minutosRestantes = Math.Max(1, (int)Math.Ceiling((existingLock.ExpiraEn - DateTime.UtcNow).TotalMinutes));

        return new BloqueoInfoDto
        {
            ClienteId = existingLock.ClienteId,
            TokenBloqueo = existingLock.TokenBloqueo,
            BloqueadoEn = existingLock.BloqueadoEn,
            ExpiraEn = existingLock.ExpiraEn,
            MinutosRestantes = minutosRestantes
        };
    }

    public async Task<int> LiberarTodosDelClienteAsync(Guid clienteId, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        var endpoints = redis.GetEndPoints();
        if (endpoints.Length == 0)
        {
            return 0;
        }

        var totalLiberados = 0;
        foreach (var endpoint in endpoints)
        {
            var server = redis.GetServer(endpoint);
            if (!server.IsConnected)
            {
                continue;
            }

            var db = redis.GetDatabase();
            foreach (var key in server.Keys(pattern: $"{KeyPrefix}*"))
            {
                cancellationToken.ThrowIfCancellationRequested();
                var value = await db.StringGetAsync(key);
                if (!value.HasValue)
                {
                    continue;
                }

                var existingLock = Deserialize(value!);
                if (existingLock?.ClienteId != clienteId)
                {
                    continue;
                }

                if (await db.KeyDeleteAsync(key))
                {
                    totalLiberados++;
                }
            }
        }

        return totalLiberados;
    }

    public static string BuildKey(Guid barberoId, DateOnly fecha, TimeOnly horaInicio)
    {
        return $"{KeyPrefix}{barberoId}:{fecha:yyyy-MM-dd}:{horaInicio:HH\\:mm}";
    }

    private static SlotBloqueoRedisModel? Deserialize(RedisValue redisValue)
    {
        return JsonSerializer.Deserialize<SlotBloqueoRedisModel>(redisValue.ToString());
    }

    private sealed class SlotBloqueoRedisModel
    {
        public Guid ClienteId { get; set; }

        public string TokenBloqueo { get; set; } = string.Empty;

        public DateTime BloqueadoEn { get; set; }

        public DateTime ExpiraEn { get; set; }
    }
}
