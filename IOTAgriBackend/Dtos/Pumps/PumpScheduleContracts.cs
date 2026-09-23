namespace IOTAgriBackend.Dtos.Pumps;

public record PumpScheduleRequest(
    bool? IsEnabled,
    int WeekdayMask,
    TimeOnly? StartTime,
    int DurationSeconds,
    string? TimeZone);

public record PumpScheduleResponse(
    Guid Id,
    bool IsEnabled,
    int WeekdayMask,
    TimeOnly StartTime,
    int DurationSeconds,
    string TimeZone,
    DateTime? LastDispatchedOccurrenceUtc,
    DateTime CreatedAt);
