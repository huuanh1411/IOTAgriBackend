namespace IOTAgriBackend.Models;

public enum PumpCommandStatus
{
    Pending,
    Acknowledged,
    Failed,
}

public enum PumpCommandSource
{
    Manual,
    Scheduled,
}

public class PumpCommand
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid DeviceId { get; set; }
    public Device? Device { get; set; }

    public bool IsOn { get; set; }
    public int? DurationSeconds { get; set; }
    public PumpCommandSource Source { get; set; }
    public PumpCommandStatus Status { get; set; } = PumpCommandStatus.Pending;
    public DateTime IssuedAt { get; set; } = DateTime.UtcNow;
    public DateTime? AcknowledgedAt { get; set; }
    public bool? AcknowledgedIsOn { get; set; }
    public string? FailureReason { get; set; }
}
