namespace Barberia.Application.Interfaces.Services;

public interface ICurrentUserService
{
    Guid? UserId { get; }

    Guid? ClienteId { get; }

    string Role { get; }

    bool IsAuthenticated { get; }

    bool IsAdmin { get; }

    bool IsAdminBarberia { get; }

    bool IsBarbero { get; }

    bool IsCliente { get; }

    Guid? BarberoId { get; }

    /// <summary>Barbería de esta petición: la del token, o la que eligió el SuperAdmin.</summary>
    Guid? BarberiaId { get; }

    /// <summary>
    /// Sin filtro de barbería: un SuperAdmin sin barbería elegida, o trabajo interno
    /// sin petición HTTP (seeder, migraciones).
    /// </summary>
    bool VeTodasLasBarberias { get; }
}
