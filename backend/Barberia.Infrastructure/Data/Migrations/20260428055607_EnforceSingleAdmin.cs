using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Barberia.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class EnforceSingleAdmin : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Rol",
                table: "clientes",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "Cliente",
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.CreateIndex(
                name: "UX_clientes_admin_rol",
                table: "clientes",
                column: "Rol",
                unique: true,
                filter: "\"Rol\" = 'Admin'");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "UX_clientes_admin_rol",
                table: "clientes");

            migrationBuilder.AlterColumn<string>(
                name: "Rol",
                table: "clientes",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(20)",
                oldMaxLength: 20,
                oldDefaultValue: "Cliente");
        }
    }
}
