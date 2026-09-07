using System.ComponentModel.DataAnnotations;

namespace IOTAgriBackend.Dtos.Auth;

public record LoginRequest(
    [Required, EmailAddress] string Email,
    [Required] string Password
);
