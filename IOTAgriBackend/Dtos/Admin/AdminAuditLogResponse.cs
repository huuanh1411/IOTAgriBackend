namespace IOTAgriBackend.Dtos.Admin;

public record AdminAuditLogResponse(
    Guid Id,
    string ActorUserId,
    string Action,
    string TargetType,
    string TargetId,
    string? PreviousValue,
    string? NewValue,
    DateTime CreatedAt);

public record AdminAuditLogPage(IReadOnlyList<AdminAuditLogResponse> Items, int Page, int PageSize, int TotalCount);
