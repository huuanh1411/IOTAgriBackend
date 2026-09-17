namespace IOTAgriBackend.Dtos.Pumps;

public record PumpCommandRequest(Guid CommandId, bool IsOn, int? DurationSeconds)
{
    public bool IsValid(int maximumDurationSeconds) =>
        CommandId != Guid.Empty &&
        (IsOn
            ? DurationSeconds is int duration && duration > 0 && duration <= maximumDurationSeconds
            : DurationSeconds is null);
}
