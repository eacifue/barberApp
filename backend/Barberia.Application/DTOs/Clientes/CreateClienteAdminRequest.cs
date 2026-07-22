namespace Barberia.Application.DTOs.Clientes;

public sealed class CreateClienteAdminRequest
{
    public Guid? BarberiaId { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Apellido { get; set; } = string.Empty;

    public string Telefono { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    public string Password { get; set; } = string.Empty;
}
