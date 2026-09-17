namespace IOTAgriBackend.Dtos.Pumps;

public record PumpCommandMessage(Guid CommandId, bool IsOn, int? DurationSeconds);

public record PumpStatusMessage(Guid? CommandId, bool IsOn);
