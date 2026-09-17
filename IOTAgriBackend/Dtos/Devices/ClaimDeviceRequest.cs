using System.ComponentModel.DataAnnotations;

namespace IOTAgriBackend.Dtos.Devices;

public record ClaimDeviceRequest(
    [Required, StringLength(64)] string Code,
    [Required, StringLength(128)] string HardwareId
);
