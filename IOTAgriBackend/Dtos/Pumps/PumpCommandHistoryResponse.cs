using IOTAgriBackend.Models;

namespace IOTAgriBackend.Dtos.Pumps;

public record PumpCommandHistoryResponse(
    Guid Id,
    bool IsOn,
    int? DurationSeconds,
    PumpCommandSource Source,
    PumpCommandStatus Status,
    DateTime IssuedAt,
    DateTime? AcknowledgedAt,
    bool? AcknowledgedIsOn,
    string? FailureReason
);

public record PumpCommandHistoryPage(
    IReadOnlyList<PumpCommandHistoryResponse> Items,
    int Page,
    int PageSize,
    int TotalCount
);
