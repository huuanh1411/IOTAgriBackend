namespace IOTAgriBackend.Dtos.Devices;

public record ClaimDeviceResponse(
    string DeviceKey,
    string MqttHost,
    int MqttPort,
    bool UseTls
);
