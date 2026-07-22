using Barberia.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Barberia.Infrastructure.Persistence.Configurations;

public class AppointmentConfiguration : IEntityTypeConfiguration<Appointment>
{
    public void Configure(EntityTypeBuilder<Appointment> builder)
    {
        builder.ToTable("appointments");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.ServiceName)
            .HasMaxLength(120)
            .IsRequired();

        builder.Property(x => x.FullName)
            .HasMaxLength(140)
            .IsRequired();

        builder.Property(x => x.Identification)
            .HasMaxLength(30)
            .IsRequired();

        builder.Property(x => x.PhoneNumber)
            .HasMaxLength(30)
            .IsRequired();

        builder.Property(x => x.Status)
            .HasConversion<string>()
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(x => x.CreatedAtUtc)
            .IsRequired();

        builder.HasIndex(x => new { x.BarberoId, x.StartTimeUtc, x.EndTimeUtc });
    }
}
