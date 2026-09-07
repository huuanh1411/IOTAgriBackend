using System.ComponentModel.DataAnnotations;

namespace IOTAgriBackend.Dtos.Auth;

public record RegisterRequest(
    [Required, EmailAddress] string Email,
    [Required, MinLength(8)] string Password,
    [Required] string FullName
);
