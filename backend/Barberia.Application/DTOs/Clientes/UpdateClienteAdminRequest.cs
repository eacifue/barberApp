namespace Barberia.Application.DTOs.Clientes;

public sealed class UpdateClienteAdminRequest
{
    public Guid? BarberiaId { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Apellido { get; set; } = string.Empty;

    public string Telefono { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    /// <summary>
    /// Si se especifica, se resetea la contraseña del cliente.
    /// </summary>
    public string? Password { get; set; }

    public bool? Activo { get; set; }
}
