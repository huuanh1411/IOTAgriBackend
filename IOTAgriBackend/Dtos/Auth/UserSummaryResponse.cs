namespace IOTAgriBackend.Dtos.Auth;

public record UserSummaryResponse(
    string Id,
    string Email,
    string FullName
);
