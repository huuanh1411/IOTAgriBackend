using IOTAgriBackend.Dtos.Alerts;
using Xunit;

namespace IOTAgriBackend.Tests;

public class DeviceAlertHistoryQueryTests
{
    [Fact]
    public void Defaults_to_first_page_of_active_alerts()
    {
        var query = new DeviceAlertHistoryQuery();

        Assert.Equal("active", query.Status);
        Assert.Equal(1, query.Page);
        Assert.Equal(50, query.PageSize);
        Assert.True(query.HasValidPagination);
        Assert.True(query.HasValidStatus);
    }

    [Theory]
    [InlineData("unknown")]
    [InlineData("ACTIVE")]
    public void Rejects_unknown_status(string status)
    {
        Assert.False(new DeviceAlertHistoryQuery(status).HasValidStatus);
    }
}
