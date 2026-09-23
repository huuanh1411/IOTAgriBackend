using IOTAgriBackend.Models;

namespace IOTAgriBackend.Dtos.Alerts;

public record DeviceAlertSettingsRequest(double? HighTemperatureC, double? LowWaterLevelPercent)
{
    public bool IsValid =>
        (HighTemperatureC is null || double.IsFinite(HighTemperatureC.Value)) &&
        (LowWaterLevelPercent is null ||
         (double.IsFinite(LowWaterLevelPercent.Value) && LowWaterLevelPercent.Value is >= 0 and <= 100));
}

public record DeviceAlertSettingsResponse(double? HighTemperatureC, double? LowWaterLevelPercent);

public record DeviceAlertResponse(
    Guid Id,
    string Type,
    double MeasuredValue,
    double Threshold,
    DateTime TriggeredAt,
    DateTime? ResolvedAt)
{
    public static DeviceAlertResponse From(DeviceAlert alert) => new(
        alert.Id,
        alert.Type == DeviceAlertType.HighTemperature ? "HIGH_TEMPERATURE" : "LOW_WATER_LEVEL",
        alert.MeasuredValue,
        alert.Threshold,
        alert.TriggeredAt,
        alert.ResolvedAt);
}

public record DeviceAlertPage(IReadOnlyList<DeviceAlertResponse> Items, int Page, int PageSize, int TotalCount);

public record DeviceAlertHistoryQuery(string Status = "active", int Page = 1, int PageSize = 50)
{
    public bool HasValidPagination => Page > 0 && PageSize is >= 1 and <= 100;
    public bool HasValidStatus => Status is "active" or "resolved" or "all";
}
