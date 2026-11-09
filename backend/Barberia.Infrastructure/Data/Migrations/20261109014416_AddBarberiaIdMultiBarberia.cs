using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Barberia.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddBarberiaIdMultiBarberia : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_clientes_Correo",
                table: "clientes");

            migrationBuilder.AddColumn<Guid>(
                name: "BarberiaId",
                table: "servicios",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "BarberiaId",
                table: "clientes",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "BarberiaId",
                table: "citas",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "BarberiaId",
                table: "barberos",
                type: "uuid",
                nullable: true);

            // Los datos que ya existen son de la barbería original (la más antigua);
            // cada cita, de la barbería de su barbero. El SuperAdmin queda sin barbería.
            migrationBuilder.Sql("""
                DO $$
                BEGIN
                    IF NOT EXISTS (SELECT 1 FROM barberias)
                       AND (EXISTS (SELECT 1 FROM servicios) OR EXISTS (SELECT 1 FROM barberos)
                            OR EXISTS (SELECT 1 FROM clientes WHERE "Rol" <> 'Admin')) THEN
                        RAISE EXCEPTION 'No hay ninguna barbería para asignarle los datos existentes. Crea una antes de migrar.';
                    END IF;
                END $$;

                UPDATE servicios SET "BarberiaId" = (SELECT "Id" FROM barberias ORDER BY "CreatedAt" LIMIT 1) WHERE "BarberiaId" IS NULL;
                UPDATE barberos SET "BarberiaId" = (SELECT "Id" FROM barberias ORDER BY "CreatedAt" LIMIT 1) WHERE "BarberiaId" IS NULL;
                UPDATE clientes SET "BarberiaId" = (SELECT "Id" FROM barberias ORDER BY "CreatedAt" LIMIT 1) WHERE "BarberiaId" IS NULL AND "Rol" <> 'Admin';
                UPDATE citas c SET "BarberiaId" = b."BarberiaId" FROM barberos b WHERE c."BarberoId" = b."Id" AND c."BarberiaId" IS NULL;
                """);

            foreach (var tabla in new[] { "servicios", "barberos", "citas" })
            {
                migrationBuilder.AlterColumn<Guid>(
                    name: "BarberiaId",
                    table: tabla,
                    type: "uuid",
                    nullable: false,
                    oldClrType: typeof(Guid),
                    oldType: "uuid",
                    oldNullable: true);
            }

            migrationBuilder.CreateIndex(
                name: "IX_servicios_BarberiaId",
                table: "servicios",
                column: "BarberiaId");

            migrationBuilder.CreateIndex(
                name: "IX_clientes_BarberiaId_Correo",
                table: "clientes",
                columns: new[] { "BarberiaId", "Correo" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UX_clientes_correo_sin_barberia",
                table: "clientes",
                column: "Correo",
                unique: true,
                filter: "\"BarberiaId\" IS NULL");

            migrationBuilder.AddCheckConstraint(
                name: "CK_clientes_solo_superadmin_sin_barberia",
                table: "clientes",
                sql: "(\"Rol\" = 'Admin') = (\"BarberiaId\" IS NULL)");

            migrationBuilder.CreateIndex(
                name: "IX_citas_BarberiaId_FechaCita",
                table: "citas",
                columns: new[] { "BarberiaId", "FechaCita" });

            migrationBuilder.CreateIndex(
                name: "IX_barberos_BarberiaId",
                table: "barberos",
                column: "BarberiaId");

            migrationBuilder.AddForeignKey(
                name: "FK_barberos_barberias_BarberiaId",
                table: "barberos",
                column: "BarberiaId",
                principalTable: "barberias",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_citas_barberias_BarberiaId",
                table: "citas",
                column: "BarberiaId",
                principalTable: "barberias",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_clientes_barberias_BarberiaId",
                table: "clientes",
                column: "BarberiaId",
                principalTable: "barberias",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_servicios_barberias_BarberiaId",
                table: "servicios",
                column: "BarberiaId",
                principalTable: "barberias",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_barberos_barberias_BarberiaId",
                table: "barberos");

            migrationBuilder.DropForeignKey(
                name: "FK_citas_barberias_BarberiaId",
                table: "citas");

            migrationBuilder.DropForeignKey(
                name: "FK_clientes_barberias_BarberiaId",
                table: "clientes");

            migrationBuilder.DropForeignKey(
                name: "FK_servicios_barberias_BarberiaId",
                table: "servicios");

            migrationBuilder.DropIndex(
                name: "IX_servicios_BarberiaId",
                table: "servicios");

            migrationBuilder.DropIndex(
                name: "IX_clientes_BarberiaId_Correo",
                table: "clientes");

            migrationBuilder.DropIndex(
                name: "UX_clientes_correo_sin_barberia",
                table: "clientes");

            migrationBuilder.DropCheckConstraint(
                name: "CK_clientes_solo_superadmin_sin_barberia",
                table: "clientes");

            migrationBuilder.DropIndex(
                name: "IX_citas_BarberiaId_FechaCita",
                table: "citas");

            migrationBuilder.DropIndex(
                name: "IX_barberos_BarberiaId",
                table: "barberos");

            migrationBuilder.DropColumn(
                name: "BarberiaId",
                table: "servicios");

            migrationBuilder.DropColumn(
                name: "BarberiaId",
                table: "clientes");

            migrationBuilder.DropColumn(
                name: "BarberiaId",
                table: "citas");

            migrationBuilder.DropColumn(
                name: "BarberiaId",
                table: "barberos");

            migrationBuilder.CreateIndex(
                name: "IX_clientes_Correo",
                table: "clientes",
                column: "Correo",
                unique: true);
        }
    }
}
