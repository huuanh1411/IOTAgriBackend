using System.ComponentModel.DataAnnotations;

namespace IOTAgriBackend.Dtos.Auth;

public record RefreshRequest(
    [Required] string RefreshToken
);
