namespace IOTAgriBackend.Dtos.Pumps;

public record PumpCommandHistoryQuery(
    DateTimeOffset? From = null,
    DateTimeOffset? To = null,
    int Page = 1,
    int PageSize = 50)
{
    public bool HasValidPagination => Page > 0 && PageSize is >= 1 and <= 100;

    public bool TryGetRange(DateTimeOffset now, out DateTime rangeStart, out DateTime rangeEnd)
    {
        rangeEnd = (To ?? now).UtcDateTime;
        rangeStart = (From ?? new DateTimeOffset(rangeEnd.AddDays(-7))).UtcDateTime;
        return rangeEnd > rangeStart && rangeEnd - rangeStart <= TimeSpan.FromDays(31);
    }
}
