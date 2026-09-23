namespace IOTAgriBackend.Models;

public class PumpScheduleOccurrence
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ScheduleId { get; set; }
    public PumpSchedule? Schedule { get; set; }
    public Guid CommandId { get; set; }
    public DateTime OccurrenceUtc { get; set; }
    public DateTime? DispatchedAt { get; set; }
}
