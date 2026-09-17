using System;
using IOTAgriBackend.Dtos.Pumps;
using Xunit;

namespace IOTAgriBackend.Tests;

public class PumpCommandHistoryQueryTests
{
    [Fact]
    public void Defaults_to_the_previous_seven_days()
    {
        var now = new DateTimeOffset(2026, 9, 17, 12, 0, 0, TimeSpan.Zero);

        var valid = new PumpCommandHistoryQuery().TryGetRange(now, out var start, out var end);

        Assert.True(valid);
        Assert.Equal(now.UtcDateTime.AddDays(-7), start);
        Assert.Equal(now.UtcDateTime, end);
    }

    [Fact]
    public void Rejects_invalid_range_and_page_size()
    {
        var now = new DateTimeOffset(2026, 9, 17, 12, 0, 0, TimeSpan.Zero);

        Assert.False(new PumpCommandHistoryQuery(now.AddDays(1), now).TryGetRange(now, out _, out _));
        Assert.False(new PumpCommandHistoryQuery(PageSize: 101).HasValidPagination);
    }
}
