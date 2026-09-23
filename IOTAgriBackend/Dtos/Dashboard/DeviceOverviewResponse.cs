using IOTAgriBackend.Dtos.Sensors;
using IOTAgriBackend.Dtos.Alerts;

namespace IOTAgriBackend.Dtos.Dashboard;

public record DeviceOverviewResponse(
    Guid DeviceId,
    string Name,
    bool IsOnline,
    DateTime? LastSeenAt,
    SensorReadingResponse? LatestReading,
    IReadOnlyList<DeviceAlertResponse> ActiveAlerts
);
