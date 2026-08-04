using System.Text.Json;
using Barberia.Application.Interfaces.Services;
using Barberia.Domain.Common;
using Barberia.Domain.Entities;
using Barberia.Domain.Enums;
using Barberia.Application.Interfaces.Persistence.Context;
using Barberia.Shared.Constants;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using BarberiaEntity = Barberia.Domain.Entities.Barberia;

namespace Barberia.Infrastructure.Data;

public class BarberiaDbContext : DbContext, IBarberiaDbContext
{
    private readonly ICurrentUserService currentUserService;

    public BarberiaDbContext(DbContextOptions<BarberiaDbContext> options, ICurrentUserService currentUserService) : base(options)
    {
        this.currentUserService = currentUserService;
    }

    public DbSet<BarberiaEntity> Barberias => Set<BarberiaEntity>();

    public DbSet<Servicio> Servicios => Set<Servicio>();

    public DbSet<Barbero> Barberos => Set<Barbero>();

    public DbSet<BarberoServicio> BarberoServicios => Set<BarberoServicio>();

    public DbSet<HorarioSemana> HorariosSemana => Set<HorarioSemana>();

    public DbSet<BarberAvailability> BarberAvailabilities => Set<BarberAvailability>();

    public DbSet<BarberDayOff> BarberDaysOff => Set<BarberDayOff>();

    public DbSet<BloqueoHorario> BloqueosHorario => Set<BloqueoHorario>();

    public DbSet<Cliente> Clientes => Set<Cliente>();

    public DbSet<Cita> Citas => Set<Cita>();

    public DbSet<Review> Reviews => Set<Review>();

    private bool BypassTenantFilter => !currentUserService.IsAuthenticated || currentUserService.IsAdmin;

    private string CurrentRole => currentUserService.Role;

    private Guid? CurrentUserId => currentUserService.UserId;

    private Guid? CurrentBarberoId => currentUserService.BarberoId;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        ConfigureBarberia(modelBuilder);
        ConfigureServicio(modelBuilder);
        ConfigureBarbero(modelBuilder);
        ConfigureBarberoServicio(modelBuilder);
        ConfigureHorarioSemana(modelBuilder);
        ConfigureBarberAvailability(modelBuilder);
        ConfigureBarberDayOff(modelBuilder);
        ConfigureBloqueoHorario(modelBuilder);
        ConfigureCliente(modelBuilder);
        ConfigureCita(modelBuilder);
        ConfigureReview(modelBuilder);
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        var entries = ChangeTracker
            .Entries<BaseEntity>()
            .Where(entry => entry.State is EntityState.Added or EntityState.Modified);

        var now = DateTime.UtcNow;

        foreach (var entry in entries)
        {
            entry.Entity.UpdatedAt = now;
            if (entry.State == EntityState.Added)
            {
                entry.Entity.CreatedAt = now;
            }
        }

        return await base.SaveChangesAsync(cancellationToken);
    }

    private static void ConfigureBarberia(ModelBuilder modelBuilder)
    {
        var diasDescansoConverter = new ValueConverter<List<DiaSemana>, string>(
            value => JsonSerializer.Serialize(value, (JsonSerializerOptions?)null),
            value => JsonSerializer.Deserialize<List<DiaSemana>>(value, (JsonSerializerOptions?)null) ?? new List<DiaSemana>());

        var diasDescansoComparer = new ValueComparer<List<DiaSemana>>(
            (left, right) => left != null && right != null && left.SequenceEqual(right),
            value => value.Aggregate(0, (hash, item) => HashCode.Combine(hash, (int)item)),
            value => value.ToList());

        modelBuilder.Entity<BarberiaEntity>(entity =>
        {
            entity.ToTable("barberias");

            entity.Property(x => x.Nombre).HasMaxLength(140).IsRequired();
            entity.Property(x => x.Descripcion).HasMaxLength(1000);
            entity.Property(x => x.Slogan).HasMaxLength(200);
            entity.Property(x => x.Telefono).HasMaxLength(30).IsRequired();
            entity.Property(x => x.Correo).HasMaxLength(150).IsRequired();
            entity.Property(x => x.SitioWeb).HasMaxLength(200);
            entity.Property(x => x.Direccion).HasMaxLength(250).IsRequired();
            entity.Property(x => x.Ciudad).HasMaxLength(120).IsRequired();
            entity.Property(x => x.Departamento).HasMaxLength(120).IsRequired();
            entity.Property(x => x.Pais).HasMaxLength(100).IsRequired();
            entity.Property(x => x.Latitud).HasPrecision(10, 7);
            entity.Property(x => x.Longitud).HasPrecision(10, 7);
            entity.Property(x => x.FotoPortada).HasMaxLength(500);
            entity.Property(x => x.DiasDescanso)
                .HasConversion(diasDescansoConverter)
                .Metadata.SetValueComparer(diasDescansoComparer);
            entity.Property(x => x.DiasDescanso).HasColumnType("jsonb");
        });
    }

    private void ConfigureServicio(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Servicio>(entity =>
        {
            entity.ToTable("servicios");

            entity.Property(x => x.Nombre).HasMaxLength(140).IsRequired();
            entity.Property(x => x.Descripcion).HasMaxLength(1000);
            entity.Property(x => x.Tipo).HasConversion<string>().HasMaxLength(30).IsRequired();
            entity.Property(x => x.DuracionMinutos).IsRequired();
            entity.Property(x => x.Precio).HasPrecision(12, 2).IsRequired();
            entity.Property(x => x.FotoUrl).HasMaxLength(500);

            entity.HasOne(x => x.Barberia)
                .WithMany(x => x.Servicios)
                .HasForeignKey(x => x.BarberiaId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasQueryFilter(x =>
                BypassTenantFilter ||
                CurrentRole == Roles.Cliente ||
                CurrentRole == Roles.AdminBarberia ||
                CurrentRole == Roles.Barbero);
        });
    }

    private void ConfigureBarbero(ModelBuilder modelBuilder)
    {
        var especialidadesConverter = new ValueConverter<List<string>, string>(
            value => JsonSerializer.Serialize(value, (JsonSerializerOptions?)null),
            value => JsonSerializer.Deserialize<List<string>>(value, (JsonSerializerOptions?)null) ?? new List<string>());

        var especialidadesComparer = new ValueComparer<List<string>>(
            (left, right) => left != null && right != null && left.SequenceEqual(right),
            value => value.Aggregate(0, (hash, item) => HashCode.Combine(hash, item.GetHashCode(StringComparison.Ordinal))),
            value => value.ToList());

        modelBuilder.Entity<Barbero>(entity =>
        {
            entity.ToTable("barberos");

            entity.Property(x => x.Nombre).HasMaxLength(120).IsRequired();
            entity.Property(x => x.Apellido).HasMaxLength(120).IsRequired();
            entity.Property(x => x.Telefono).HasMaxLength(30).IsRequired();
            entity.Property(x => x.Correo).HasMaxLength(150).IsRequired();
            entity.Property(x => x.FotoUrl).HasMaxLength(500);
            entity.Property(x => x.Biografia).HasMaxLength(1000);
            entity.Property(x => x.TokenFCM).HasMaxLength(300);
            entity.Property(x => x.RatingPromedio).HasPrecision(4, 2);
            entity.Property(x => x.Especialidades)
                .HasConversion(especialidadesConverter)
                .Metadata.SetValueComparer(especialidadesComparer);
            entity.Property(x => x.Especialidades).HasColumnType("jsonb");

            entity.HasOne(x => x.Barberia)
                .WithMany(x => x.Barberos)
                .HasForeignKey(x => x.BarberiaId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasQueryFilter(x =>
                BypassTenantFilter ||
                CurrentRole == Roles.Cliente ||
                CurrentRole == Roles.AdminBarberia ||
                CurrentRole == Roles.Barbero);
        });
    }

    private void ConfigureBarberoServicio(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<BarberoServicio>(entity =>
        {
            entity.ToTable("barbero_servicios");

            entity.HasKey(x => new { x.BarberoId, x.ServicioId });

            entity.Property(x => x.PrecioEspecial).HasPrecision(12, 2);

            entity.HasOne(x => x.Barbero)
                .WithMany(x => x.BarberoServicios)
                .HasForeignKey(x => x.BarberoId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(x => x.Servicio)
                .WithMany(x => x.BarberoServicios)
                .HasForeignKey(x => x.ServicioId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasQueryFilter(x =>
                BypassTenantFilter ||
                CurrentRole == Roles.Cliente ||
                CurrentRole == Roles.AdminBarberia ||
                CurrentRole == Roles.Barbero);
        });
    }

    private void ConfigureHorarioSemana(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<HorarioSemana>(entity =>
        {
            entity.ToTable("horarios_semana");

            entity.Property(x => x.DiaSemana).HasConversion<int>().IsRequired();
            entity.Property(x => x.IntervaloCitasMinutos).HasDefaultValue(30).IsRequired();

            entity.HasOne(x => x.Barbero)
                .WithMany(x => x.HorariosSemana)
                .HasForeignKey(x => x.BarberoId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasQueryFilter(x =>
                BypassTenantFilter ||
                CurrentRole == Roles.Cliente ||
                CurrentRole == Roles.AdminBarberia ||
                CurrentRole == Roles.Barbero);
        });
    }

    private void ConfigureBloqueoHorario(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<BloqueoHorario>(entity =>
        {
            entity.ToTable("bloqueos_horario");

            entity.Property(x => x.Motivo).HasMaxLength(500).IsRequired();

            entity.HasOne(x => x.Barbero)
                .WithMany(x => x.BloqueosHorario)
                .HasForeignKey(x => x.BarberoId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasQueryFilter(x =>
                BypassTenantFilter ||
                CurrentRole == Roles.Cliente ||
                CurrentRole == Roles.AdminBarberia ||
                CurrentRole == Roles.Barbero);
        });
    }

    private void ConfigureBarberAvailability(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<BarberAvailability>(entity =>
        {
            entity.ToTable("barber_availabilities");

            entity.Property(x => x.DayOfWeek).HasConversion<int>().IsRequired();
            entity.Property(x => x.StartTime).IsRequired();
            entity.Property(x => x.EndTime).IsRequired();
            entity.Property(x => x.IsActive).HasDefaultValue(true).IsRequired();

            entity.HasIndex(x => new { x.BarberId, x.DayOfWeek, x.StartTime, x.EndTime })
                .HasDatabaseName("IX_barber_availabilities_barber_day_range");

            entity.HasOne(x => x.Barber)
                .WithMany(x => x.Availabilities)
                .HasForeignKey(x => x.BarberId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasQueryFilter(x =>
                BypassTenantFilter ||
                CurrentRole == Roles.Cliente ||
                CurrentRole == Roles.AdminBarberia ||
                CurrentRole == Roles.Barbero);
        });
    }

    private void ConfigureBarberDayOff(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<BarberDayOff>(entity =>
        {
            entity.ToTable("barber_day_offs");

            entity.Property(x => x.Date).IsRequired();
            entity.Property(x => x.Reason).HasMaxLength(300);

            entity.HasIndex(x => new { x.BarberId, x.Date })
                .IsUnique()
                .HasDatabaseName("UX_barber_day_offs_barber_date");

            entity.HasOne(x => x.Barber)
                .WithMany(x => x.DaysOff)
                .HasForeignKey(x => x.BarberId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasQueryFilter(x =>
                BypassTenantFilter ||
                CurrentRole == Roles.Cliente ||
                CurrentRole == Roles.AdminBarberia ||
                CurrentRole == Roles.Barbero);
        });
    }

    private void ConfigureCliente(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Cliente>(entity =>
        {
            entity.ToTable("clientes");

            entity.Property(x => x.Rol)
                .HasMaxLength(30)
                .HasDefaultValue(Roles.Cliente)
                .IsRequired();

            entity.Property(x => x.BarberiaId);
            entity.Property(x => x.BarberoId);

            entity.Property(x => x.Nombre).HasMaxLength(120).IsRequired();
            entity.Property(x => x.Apellido).HasMaxLength(120).IsRequired();
            entity.Property(x => x.Telefono).HasMaxLength(30).IsRequired();
            entity.Property(x => x.Correo).HasMaxLength(150).IsRequired();
            entity.Property(x => x.PasswordHash).HasMaxLength(500).IsRequired();
            entity.Property(x => x.FotoUrl).HasMaxLength(500);
            entity.Property(x => x.TokenFCM).HasMaxLength(300);

            entity.HasIndex(x => x.Correo).IsUnique();

            // Garantiza que exista como máximo 1 usuario con Rol='Admin'.
            entity.HasIndex(x => x.Rol)
                .IsUnique()
                .HasDatabaseName("UX_clientes_admin_rol")
                .HasFilter("\"Rol\" = 'Admin'");

            entity.ToTable(table =>
            {
                table.HasCheckConstraint(
                    "CK_clientes_role_barberia",
                    "(\"Rol\" = 'Admin' AND \"BarberiaId\" IS NULL) OR (\"Rol\" = 'AdministradorBarberia' AND \"BarberiaId\" IS NOT NULL) OR (\"Rol\" = 'Barbero' AND \"BarberiaId\" IS NOT NULL) OR (\"Rol\" = 'Cliente')");
            });

            entity.HasQueryFilter(x =>
                BypassTenantFilter ||
                CurrentRole == Roles.AdminBarberia ||
                ((CurrentRole == Roles.Barbero || CurrentRole == Roles.Cliente) && CurrentUserId != null && x.Id == CurrentUserId));
        });
    }

    private void ConfigureCita(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Cita>(entity =>
        {
            entity.ToTable("citas");

            entity.Property(x => x.Estado).HasConversion<string>().HasMaxLength(30).IsRequired();
            entity.Property(x => x.Notas).HasMaxLength(1000);
            entity.Property(x => x.PrecioFinal).HasPrecision(12, 2).IsRequired();
            entity.Property(x => x.TokenRedisBloqueo).HasMaxLength(120);

            entity.HasIndex(x => new { x.BarberoId, x.FechaCita, x.HoraInicio });

            entity.HasOne(x => x.Cliente)
                .WithMany(x => x.Citas)
                .HasForeignKey(x => x.ClienteId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(x => x.Barbero)
                .WithMany(x => x.Citas)
                .HasForeignKey(x => x.BarberoId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(x => x.Servicio)
                .WithMany(x => x.Citas)
                .HasForeignKey(x => x.ServicioId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasQueryFilter(x =>
                BypassTenantFilter ||
                CurrentRole == Roles.AdminBarberia ||
                (CurrentRole == Roles.Barbero && CurrentBarberoId != null && x.BarberoId == CurrentBarberoId) ||
                (CurrentRole == Roles.Cliente && CurrentUserId != null && x.ClienteId == CurrentUserId));
        });
    }

    private void ConfigureReview(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Review>(entity =>
        {
            entity.ToTable("reviews");

            entity.Property(x => x.Calificacion).IsRequired();
            entity.Property(x => x.Comentario).HasMaxLength(1000);

            entity.HasIndex(x => x.CitaId).IsUnique();

            entity.HasOne(x => x.Cliente)
                .WithMany(x => x.Reviews)
                .HasForeignKey(x => x.ClienteId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasQueryFilter(x =>
                BypassTenantFilter ||
                (CurrentRole == Roles.Cliente && CurrentUserId != null && x.ClienteId == CurrentUserId) ||
                (CurrentRole == Roles.Barbero && CurrentBarberoId != null && x.BarberoId == CurrentBarberoId) ||
                CurrentRole == Roles.AdminBarberia);

            entity.HasOne(x => x.Barbero)
                .WithMany(x => x.Reviews)
                .HasForeignKey(x => x.BarberoId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(x => x.Cita)
                .WithOne(x => x.Review)
                .HasForeignKey<Review>(x => x.CitaId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
