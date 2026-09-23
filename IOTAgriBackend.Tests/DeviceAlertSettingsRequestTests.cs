using IOTAgriBackend.Dtos.Alerts;
using Xunit;

namespace IOTAgriBackend.Tests;

public class DeviceAlertSettingsRequestTests
{
    [Fact]
    public void Allows_disabled_or_finite_thresholds()
    {
        Assert.True(new DeviceAlertSettingsRequest(null, null).IsValid);
        Assert.True(new DeviceAlertSettingsRequest(35, 20).IsValid);
    }

    [Fact]
    public void Rejects_non_finite_and_out_of_range_water_thresholds()
    {
        Assert.False(new DeviceAlertSettingsRequest(double.NaN, 20).IsValid);
        Assert.False(new DeviceAlertSettingsRequest(35, -0.1).IsValid);
        Assert.False(new DeviceAlertSettingsRequest(35, 100.1).IsValid);
    }
}
