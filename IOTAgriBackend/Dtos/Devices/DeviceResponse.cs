namespace IOTAgriBackend.Dtos.Devices;

public record DeviceResponse(
    Guid Id,
    string Name,
    bool IsOnline,
    DateTime? LastSeenAt,
    DateTime CreatedAt
);
