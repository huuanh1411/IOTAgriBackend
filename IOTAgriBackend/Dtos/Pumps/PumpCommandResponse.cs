using IOTAgriBackend.Models;

namespace IOTAgriBackend.Dtos.Pumps;

public record PumpCommandResponse(
    Guid Id,
    bool IsOn,
    int? DurationSeconds,
    PumpCommandStatus Status,
    DateTime IssuedAt,
    DateTime? AcknowledgedAt,
    bool? AcknowledgedIsOn
);
