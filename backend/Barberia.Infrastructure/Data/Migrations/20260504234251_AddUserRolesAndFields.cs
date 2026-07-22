using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Barberia.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddUserRolesAndFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Rol",
                table: "clientes",
                type: "character varying(30)",
                maxLength: 30,
                nullable: false,
                defaultValue: "Cliente",
                oldClrType: typeof(string),
                oldType: "character varying(20)",
                oldMaxLength: 20,
                oldDefaultValue: "Cliente");

            migrationBuilder.AddColumn<Guid>(
                name: "BarberiaId",
                table: "clientes",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "BarberoId",
                table: "clientes",
                type: "uuid",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BarberiaId",
                table: "clientes");

            migrationBuilder.DropColumn(
                name: "BarberoId",
                table: "clientes");

            migrationBuilder.AlterColumn<string>(
                name: "Rol",
                table: "clientes",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "Cliente",
                oldClrType: typeof(string),
                oldType: "character varying(30)",
                oldMaxLength: 30,
                oldDefaultValue: "Cliente");
        }
    }
}
