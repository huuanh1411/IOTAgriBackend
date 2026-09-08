using IOTAgriBackend.Dtos.Sensors;

namespace IOTAgriBackend.Dtos.Dashboard;

public record DeviceOverviewResponse(
    Guid DeviceId,
    string Name,
    bool IsOnline,
    DateTime? LastSeenAt,
    SensorReadingResponse? LatestReading
);
