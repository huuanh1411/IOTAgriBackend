namespace IOTAgriBackend.Models;

public class Device
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Name { get; set; } = string.Empty;

    // Secret credential used by the ESP32 to authenticate ingestion/control calls.
    public string DeviceKey { get; set; } = string.Empty;

    public string? OwnerId { get; set; }
    public ApplicationUser? Owner { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public bool IsOnline { get; set; }
    public DateTime? LastSeenAt { get; set; }
    public bool IsPumpOn { get; set; }
    public DateTime? PumpStatusUpdatedAt { get; set; }
    public double? HighTemperatureAlertC { get; set; }
    public double? LowWaterLevelAlertPercent { get; set; }

    public string? ProvisioningCodeHash { get; set; }
    public DateTime? ProvisioningCodeExpiresAt { get; set; }
    public string? ProvisionedHardwareId { get; set; }
    public DateTime? ProvisionedAt { get; set; }

    public ICollection<SensorReading> Readings { get; set; } = new List<SensorReading>();
    public ICollection<PumpCommand> PumpCommands { get; set; } = new List<PumpCommand>();
    public ICollection<PumpSchedule> PumpSchedules { get; set; } = new List<PumpSchedule>();
    public ICollection<DeviceAlert> Alerts { get; set; } = new List<DeviceAlert>();
}
