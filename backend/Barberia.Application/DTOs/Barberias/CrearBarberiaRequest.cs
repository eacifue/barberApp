namespace Barberia.Application.DTOs.Barberias;

/// <summary>Alta de una barbería por el SuperAdmin, junto con su primer administrador.</summary>
public sealed class CrearBarberiaRequest : UpsertBarberiaRequest
{
    public NuevoAdministradorRequest Administrador { get; set; } = new();
}

public sealed class NuevoAdministradorRequest
{
    public string Nombre { get; set; } = string.Empty;

    public string Apellido { get; set; } = string.Empty;

    public string Telefono { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    public string Password { get; set; } = string.Empty;
}
