namespace IOTAgriBackend.Dtos.Admin;

public record AdminDeviceResponse(
    Guid Id,
    string Name,
    string? OwnerId,
    string? OwnerEmail,
    bool IsOnline,
    DateTime? LastSeenAt,
    DateTime CreatedAt);

public record AdminDevicePage(IReadOnlyList<AdminDeviceResponse> Items, int Page, int PageSize, int TotalCount);
