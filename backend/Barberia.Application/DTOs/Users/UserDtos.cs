namespace Barberia.Application.DTOs.Users;

public record UserDto(
    Guid Id,
    string Nombre,
    string Apellido,
    string Correo,
    string Telefono,
    string Rol,
    Guid? BarberiaId,
    Guid? BarberoId,
    bool Activo,
    DateTime CreatedAt
);

public record CreateUserRequest(
    string Nombre,
    string Apellido,
    string Correo,
    string Telefono,
    string Password,
    string Rol,
    Guid? BarberiaId = null,
    Guid? BarberoId = null
);

public record UpdateUserRequest(
    string? Nombre,
    string? Apellido,
    string? Telefono,
    string? Rol,
    Guid? BarberiaId,
    Guid? BarberoId,
    bool? Activo
);
