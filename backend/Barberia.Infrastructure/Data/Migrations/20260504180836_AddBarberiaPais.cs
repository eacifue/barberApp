using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Barberia.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddBarberiaPais : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Pais",
                table: "barberias",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            // Actualizar registros existentes: si ya tienen Departamento = 'Antioquia', son de Colombia
            migrationBuilder.Sql("""
                UPDATE barberias
                SET "Pais" = 'Colombia'
                WHERE "Pais" = ''
                  AND ("Departamento" ILIKE '%antioquia%'
                    OR "Ciudad" ILIKE '%medell%'
                    OR "Ciudad" ILIKE '%bogot%'
                    OR "Ciudad" ILIKE '%cali%'
                    OR "Ciudad" ILIKE '%barranquilla%'
                    OR "Ciudad" ILIKE '%cartagena%');
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Pais",
                table: "barberias");
        }
    }
}
