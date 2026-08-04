using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Barberia.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class RemoveBarberiaIdFromBarberoServicioCliente : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_barberos_barberias_BarberiaId",
                table: "barberos");

            migrationBuilder.DropForeignKey(
                name: "FK_servicios_barberias_BarberiaId",
                table: "servicios");

            migrationBuilder.DropIndex(
                name: "IX_servicios_BarberiaId",
                table: "servicios");

            migrationBuilder.DropCheckConstraint(
                name: "CK_clientes_role_barberia",
                table: "clientes");

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
                table: "barberos");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "BarberiaId",
                table: "servicios",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "BarberiaId",
                table: "clientes",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "BarberiaId",
                table: "barberos",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.CreateIndex(
                name: "IX_servicios_BarberiaId",
                table: "servicios",
                column: "BarberiaId");

            migrationBuilder.AddCheckConstraint(
                name: "CK_clientes_role_barberia",
                table: "clientes",
                sql: "(\"Rol\" = 'Admin' AND \"BarberiaId\" IS NULL) OR (\"Rol\" = 'AdministradorBarberia' AND \"BarberiaId\" IS NOT NULL) OR (\"Rol\" = 'Barbero' AND \"BarberiaId\" IS NOT NULL) OR (\"Rol\" = 'Cliente')");

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
                name: "FK_servicios_barberias_BarberiaId",
                table: "servicios",
                column: "BarberiaId",
                principalTable: "barberias",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
