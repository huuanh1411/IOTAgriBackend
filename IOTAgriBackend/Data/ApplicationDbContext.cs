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
    }
}
