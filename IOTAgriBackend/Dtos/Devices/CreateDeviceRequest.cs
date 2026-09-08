using System.ComponentModel.DataAnnotations;

namespace IOTAgriBackend.Dtos.Devices;

public record CreateDeviceRequest(
    [Required] string Name
);
