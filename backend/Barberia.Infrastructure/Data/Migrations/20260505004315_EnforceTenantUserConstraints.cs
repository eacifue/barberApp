using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Barberia.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class EnforceTenantUserConstraints : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE clientes
                ADD CONSTRAINT "CK_clientes_role_barberia"
                CHECK (("Rol" = 'Admin' AND "BarberiaId" IS NULL)
                    OR ("Rol" = 'AdministradorBarberia' AND "BarberiaId" IS NOT NULL)
                    OR ("Rol" = 'Barbero' AND "BarberiaId" IS NOT NULL)
                    OR ("Rol" = 'Cliente')) NOT VALID;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("ALTER TABLE clientes DROP CONSTRAINT IF EXISTS \"CK_clientes_role_barberia\";");
        }
    }
}
