namespace IOTAgriBackend.Dtos.Auth;

public record AuthResponse(
    string AccessToken,
    string RefreshToken,
    DateTime ExpiresAt
);
