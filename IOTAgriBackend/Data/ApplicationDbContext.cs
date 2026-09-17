using IOTAgriBackend.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Data;

public class ApplicationDbContext : IdentityDbContext<ApplicationUser, IdentityRole, string>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Device> Devices => Set<Device>();
    public DbSet<SensorReading> SensorReadings => Set<SensorReading>();
    public DbSet<PumpCommand> PumpCommands => Set<PumpCommand>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<RefreshToken>(entity =>
        {
            entity.HasIndex(rt => rt.Token).IsUnique();

            entity.HasOne(rt => rt.User)
                .WithMany()
                .HasForeignKey(rt => rt.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<Device>(entity =>
        {
            entity.HasIndex(d => d.DeviceKey).IsUnique();
            entity.HasIndex(d => d.ProvisionedHardwareId).IsUnique();

            entity.HasOne(d => d.Owner)
                .WithMany(u => u.Devices)
                .HasForeignKey(d => d.OwnerId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<SensorReading>(entity =>
        {
            entity.HasOne(r => r.Device)
                .WithMany(d => d.Readings)
                .HasForeignKey(r => r.DeviceId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(r => new { r.DeviceId, r.RecordedAt });
        });

        builder.Entity<PumpCommand>(entity =>
        {
            entity.Property(c => c.FailureReason).HasMaxLength(512);
            entity.ToTable(table => table.HasCheckConstraint(
                "CK_PumpCommands_DurationSeconds",
                "\"DurationSeconds\" IS NULL OR \"DurationSeconds\" > 0"));
            entity.HasIndex(c => new { c.DeviceId, c.IssuedAt });

            entity.HasOne(c => c.Device)
                .WithMany(d => d.PumpCommands)
                .HasForeignKey(c => c.DeviceId)
                .OnDelete(DeleteBehavior.Cascade);

        });
    }
}
