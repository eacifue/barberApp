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

    Guid? BarberiaId { get; }

    Guid? BarberoId { get; }
}
