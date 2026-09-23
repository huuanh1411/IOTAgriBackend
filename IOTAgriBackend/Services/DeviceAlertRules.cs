using IOTAgriBackend.Models;

namespace IOTAgriBackend.Services;

public static class DeviceAlertRules
{
    public static bool? IsUnsafe(
        DeviceAlertType type,
        double? temperature,
        double? waterLevel,
        double? highTemperatureAlertC,
        double? lowWaterLevelAlertPercent) => type switch
    {
        DeviceAlertType.HighTemperature when temperature is double value && highTemperatureAlertC is double threshold => value >= threshold,
        DeviceAlertType.LowWaterLevel when waterLevel is double value && lowWaterLevelAlertPercent is double threshold => value <= threshold,
        _ => null,
    };
}
