namespace IOTAgriBackend.Dtos.Sensors;

public record SensorReadingRequest(
    double? Temperature,
    double? Humidity,
    double? Ph,
    double? Tds,
    double? WaterLevel
);
