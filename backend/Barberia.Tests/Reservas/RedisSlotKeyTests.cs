using Barberia.Infrastructure.Redis;

namespace Barberia.Tests.Reservas;

public sealed class RedisSlotKeyTests
{
    [Fact]
    public void La_clave_de_un_bloqueo_se_lee_de_vuelta_con_barbero_fecha_y_hora()
    {
        var barberoId = Guid.NewGuid();
        var key = RedisSlotBloqueoService.BuildKey(barberoId, new DateOnly(2026, 11, 7), new TimeOnly(14, 30));

        Assert.True(RedisSlotBloqueoService.TryParseKey(key, out var b, out var f, out var h));
        Assert.Equal((barberoId, new DateOnly(2026, 11, 7), new TimeOnly(14, 30)), (b, f, h));
    }

    [Theory]
    [InlineData("barberia:cache:algo")]
    [InlineData("barberia:slot:no-es-guid:2026-11-07:14:30")]
    [InlineData("barberia:slot:6f1c1d7e-0000-0000-0000-000000000000:7-11-2026:14:30")]
    public void Una_clave_ajena_o_mal_formada_se_ignora(string key)
    {
        Assert.False(RedisSlotBloqueoService.TryParseKey(key, out _, out _, out _));
    }
}
