namespace IOTAgriBackend.Models;

public class DeviceAlert
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid DeviceId { get; set; }
    public Device? Device { get; set; }
    public DeviceAlertType Type { get; set; }
    public double MeasuredValue { get; set; }
    public double Threshold { get; set; }
    public DateTime TriggeredAt { get; set; } = DateTime.UtcNow;
    public DateTime? ResolvedAt { get; set; }
}

public enum DeviceAlertType
{
    HighTemperature,
    LowWaterLevel,
}
