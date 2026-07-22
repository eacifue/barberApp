using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Barberia.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "barberias",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Nombre = table.Column<string>(type: "character varying(140)", maxLength: 140, nullable: false),
                    Descripcion = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    Slogan = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Telefono = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    Correo = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    SitioWeb = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Direccion = table.Column<string>(type: "character varying(250)", maxLength: 250, nullable: false),
                    Ciudad = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    Departamento = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    Latitud = table.Column<decimal>(type: "numeric(10,7)", precision: 10, scale: 7, nullable: false),
                    Longitud = table.Column<decimal>(type: "numeric(10,7)", precision: 10, scale: 7, nullable: false),
                    FotoPortada = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    HoraApertura = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    HoraCierre = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    DiasDescanso = table.Column<string>(type: "jsonb", nullable: false),
                    Activa = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Activo = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_barberias", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "clientes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Nombre = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    Apellido = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    Telefono = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    Correo = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    PasswordHash = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    FotoUrl = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    TokenFCM = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: true),
                    UltimaCita = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    TotalCitas = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Activo = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_clientes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "barberos",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    BarberiaId = table.Column<Guid>(type: "uuid", nullable: false),
                    Nombre = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    Apellido = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    Telefono = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    Correo = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    FotoUrl = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Biografia = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    AniosExperiencia = table.Column<int>(type: "integer", nullable: false),
                    Especialidades = table.Column<string>(type: "jsonb", nullable: false),
                    TokenFCM = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: true),
                    Disponible = table.Column<bool>(type: "boolean", nullable: false),
                    RatingPromedio = table.Column<decimal>(type: "numeric(4,2)", precision: 4, scale: 2, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Activo = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_barberos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_barberos_barberias_BarberiaId",
                        column: x => x.BarberiaId,
                        principalTable: "barberias",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "servicios",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    BarberiaId = table.Column<Guid>(type: "uuid", nullable: false),
                    Nombre = table.Column<string>(type: "character varying(140)", maxLength: 140, nullable: false),
                    Descripcion = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    Tipo = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    DuracionMinutos = table.Column<int>(type: "integer", nullable: false),
                    Precio = table.Column<decimal>(type: "numeric(12,2)", precision: 12, scale: 2, nullable: false),
                    FotoUrl = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Activo = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_servicios", x => x.Id);
                    table.ForeignKey(
                        name: "FK_servicios_barberias_BarberiaId",
                        column: x => x.BarberiaId,
                        principalTable: "barberias",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "bloqueos_horario",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    BarberoId = table.Column<Guid>(type: "uuid", nullable: false),
                    FechaInicio = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    FechaFin = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Motivo = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Activo = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_bloqueos_horario", x => x.Id);
                    table.ForeignKey(
                        name: "FK_bloqueos_horario_barberos_BarberoId",
                        column: x => x.BarberoId,
                        principalTable: "barberos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "horarios_semana",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    BarberoId = table.Column<Guid>(type: "uuid", nullable: false),
                    DiaSemana = table.Column<int>(type: "integer", nullable: false),
                    HoraInicio = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    HoraFin = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    IntervaloCitasMinutos = table.Column<int>(type: "integer", nullable: false, defaultValue: 30),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Activo = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_horarios_semana", x => x.Id);
                    table.ForeignKey(
                        name: "FK_horarios_semana_barberos_BarberoId",
                        column: x => x.BarberoId,
                        principalTable: "barberos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "barbero_servicios",
                columns: table => new
                {
                    BarberoId = table.Column<Guid>(type: "uuid", nullable: false),
                    ServicioId = table.Column<Guid>(type: "uuid", nullable: false),
                    PrecioEspecial = table.Column<decimal>(type: "numeric(12,2)", precision: 12, scale: 2, nullable: true),
                    Activo = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_barbero_servicios", x => new { x.BarberoId, x.ServicioId });
                    table.ForeignKey(
                        name: "FK_barbero_servicios_barberos_BarberoId",
                        column: x => x.BarberoId,
                        principalTable: "barberos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_barbero_servicios_servicios_ServicioId",
                        column: x => x.ServicioId,
                        principalTable: "servicios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "citas",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ClienteId = table.Column<Guid>(type: "uuid", nullable: false),
                    BarberoId = table.Column<Guid>(type: "uuid", nullable: false),
                    ServicioId = table.Column<Guid>(type: "uuid", nullable: false),
                    FechaCita = table.Column<DateOnly>(type: "date", nullable: false),
                    HoraInicio = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    HoraFin = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    Estado = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    Notas = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    PrecioFinal = table.Column<decimal>(type: "numeric(12,2)", precision: 12, scale: 2, nullable: false),
                    TokenRedisBloqueo = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Activo = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_citas", x => x.Id);
                    table.ForeignKey(
                        name: "FK_citas_barberos_BarberoId",
                        column: x => x.BarberoId,
                        principalTable: "barberos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_citas_clientes_ClienteId",
                        column: x => x.ClienteId,
                        principalTable: "clientes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_citas_servicios_ServicioId",
                        column: x => x.ServicioId,
                        principalTable: "servicios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "reviews",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ClienteId = table.Column<Guid>(type: "uuid", nullable: false),
                    BarberoId = table.Column<Guid>(type: "uuid", nullable: false),
                    CitaId = table.Column<Guid>(type: "uuid", nullable: false),
                    Calificacion = table.Column<int>(type: "integer", nullable: false),
                    Comentario = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    Visible = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Activo = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reviews", x => x.Id);
                    table.ForeignKey(
                        name: "FK_reviews_barberos_BarberoId",
                        column: x => x.BarberoId,
                        principalTable: "barberos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reviews_citas_CitaId",
                        column: x => x.CitaId,
                        principalTable: "citas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reviews_clientes_ClienteId",
                        column: x => x.ClienteId,
                        principalTable: "clientes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_barbero_servicios_ServicioId",
                table: "barbero_servicios",
                column: "ServicioId");

            migrationBuilder.CreateIndex(
                name: "IX_barberos_BarberiaId",
                table: "barberos",
                column: "BarberiaId");

            migrationBuilder.CreateIndex(
                name: "IX_bloqueos_horario_BarberoId",
                table: "bloqueos_horario",
                column: "BarberoId");

            migrationBuilder.CreateIndex(
                name: "IX_citas_BarberoId_FechaCita_HoraInicio",
                table: "citas",
                columns: new[] { "BarberoId", "FechaCita", "HoraInicio" });

            migrationBuilder.CreateIndex(
                name: "IX_citas_ClienteId",
                table: "citas",
                column: "ClienteId");

            migrationBuilder.CreateIndex(
                name: "IX_citas_ServicioId",
                table: "citas",
                column: "ServicioId");

            migrationBuilder.CreateIndex(
                name: "IX_clientes_Correo",
                table: "clientes",
                column: "Correo",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_horarios_semana_BarberoId",
                table: "horarios_semana",
                column: "BarberoId");

            migrationBuilder.CreateIndex(
                name: "IX_reviews_BarberoId",
                table: "reviews",
                column: "BarberoId");

            migrationBuilder.CreateIndex(
                name: "IX_reviews_CitaId",
                table: "reviews",
                column: "CitaId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reviews_ClienteId",
                table: "reviews",
                column: "ClienteId");

            migrationBuilder.CreateIndex(
                name: "IX_servicios_BarberiaId",
                table: "servicios",
                column: "BarberiaId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "barbero_servicios");

            migrationBuilder.DropTable(
                name: "bloqueos_horario");

            migrationBuilder.DropTable(
                name: "horarios_semana");

            migrationBuilder.DropTable(
                name: "reviews");

            migrationBuilder.DropTable(
                name: "citas");

            migrationBuilder.DropTable(
                name: "barberos");

            migrationBuilder.DropTable(
                name: "clientes");

            migrationBuilder.DropTable(
                name: "servicios");

            migrationBuilder.DropTable(
                name: "barberias");
        }
    }
}
