using IOTAgriBackend.Models;

namespace IOTAgriBackend.Services;

public static class PumpScheduleRules
{
    private const int AllDaysMask = 0b1111111;
    private const long TicksPerWeek = TimeSpan.TicksPerDay * 7;

    public static string? Validate(bool? isEnabled, int weekdayMask, TimeOnly? startTime, int durationSeconds, string? timeZone, int maximumDurationSeconds)
    {
        if (isEnabled is null) return "isEnabled is required.";
        if (weekdayMask <= 0 || (weekdayMask & ~AllDaysMask) != 0) return "weekdayMask must include one or more days from Sunday (1) through Saturday (64).";
        if (startTime is null) return "startTime is required.";
        if (durationSeconds <= 0 || durationSeconds > maximumDurationSeconds) return $"durationSeconds must be between 1 and {maximumDurationSeconds}.";
        if (string.IsNullOrWhiteSpace(timeZone) || !TimeZoneInfo.TryConvertIanaIdToWindowsId(timeZone, out _)) return "timeZone must be a valid IANA time zone.";
        return null;
    }

    public static bool Overlaps(PumpSchedule candidate, IEnumerable<PumpSchedule> schedules)
    {
        if (!candidate.IsEnabled) return false;

        return schedules.Where(schedule => schedule.IsEnabled && schedule.Id != candidate.Id)
            .Any(schedule => Occurrences(candidate).Any(candidateStart =>
                Occurrences(schedule).Any(existingStart => IntervalsOverlap(candidateStart, candidate.DurationSeconds, existingStart, schedule.DurationSeconds))));
    }

    private static IEnumerable<long> Occurrences(PumpSchedule schedule)
    {
        for (var day = 0; day < 7; day++)
        {
            if ((schedule.WeekdayMask & (1 << day)) != 0)
                yield return (TimeSpan.TicksPerDay * day) + schedule.StartTime.Ticks;
        }
    }

    private static bool IntervalsOverlap(long firstStart, int firstDurationSeconds, long secondStart, int secondDurationSeconds)
    {
        var firstEnd = firstStart + TimeSpan.FromSeconds(firstDurationSeconds).Ticks;
        var secondEnd = secondStart + TimeSpan.FromSeconds(secondDurationSeconds).Ticks;

        return Overlaps(firstStart, firstEnd, secondStart, secondEnd) ||
            Overlaps(firstStart, firstEnd, secondStart + TicksPerWeek, secondEnd + TicksPerWeek) ||
            Overlaps(firstStart, firstEnd, secondStart - TicksPerWeek, secondEnd - TicksPerWeek);
    }

    public static bool TryGetDueOccurrenceUtc(PumpSchedule schedule, DateTime utcNow, TimeSpan dueWindow, out DateTime occurrenceUtc)
    {
        occurrenceUtc = default;
        if (!schedule.IsEnabled || dueWindow <= TimeSpan.Zero) return false;

        TimeZoneInfo timeZone;
        try
        {
            timeZone = TimeZoneInfo.FindSystemTimeZoneById(schedule.TimeZone);
        }
        catch (TimeZoneNotFoundException)
        {
            return false;
        }
        catch (InvalidTimeZoneException)
        {
            return false;
        }

        var localNow = TimeZoneInfo.ConvertTimeFromUtc(utcNow, timeZone);
        if ((schedule.WeekdayMask & (1 << (int)localNow.DayOfWeek)) == 0) return false;

        var localOccurrence = DateTime.SpecifyKind(localNow.Date + schedule.StartTime.ToTimeSpan(), DateTimeKind.Unspecified);
        if (timeZone.IsInvalidTime(localOccurrence)) return false;

        occurrenceUtc = TimeZoneInfo.ConvertTimeToUtc(localOccurrence, timeZone);
        return occurrenceUtc <= utcNow && utcNow - occurrenceUtc <= dueWindow;
    }

    private static bool Overlaps(long firstStart, long firstEnd, long secondStart, long secondEnd) =>
        firstStart < secondEnd && secondStart < firstEnd;
}
