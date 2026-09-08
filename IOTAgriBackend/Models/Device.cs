namespace IOTAgriBackend.Models;

public class Device
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Name { get; set; } = string.Empty;

    // Secret credential used by the ESP32 to authenticate ingestion/control calls.
    public string DeviceKey { get; set; } = string.Empty;

    public string OwnerId { get; set; } = string.Empty;
    public ApplicationUser? Owner { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public bool IsOnline { get; set; }
    public DateTime? LastSeenAt { get; set; }

    public ICollection<SensorReading> Readings { get; set; } = new List<SensorReading>();
}
