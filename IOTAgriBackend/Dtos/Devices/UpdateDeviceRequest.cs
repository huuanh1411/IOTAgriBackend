using System.ComponentModel.DataAnnotations;

namespace IOTAgriBackend.Dtos.Devices;

public record UpdateDeviceRequest(
    [Required] string Name
);
