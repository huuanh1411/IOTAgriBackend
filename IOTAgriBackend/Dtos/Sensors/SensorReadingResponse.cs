namespace IOTAgriBackend.Dtos.Sensors;

public record SensorReadingResponse(
    Guid Id,
    double? Temperature,
    double? Humidity,
    double? Ph,
    double? Tds,
    double? WaterLevel,
    DateTime RecordedAt
);
