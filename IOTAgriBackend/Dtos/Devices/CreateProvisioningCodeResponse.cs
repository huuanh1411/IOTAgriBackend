namespace IOTAgriBackend.Dtos.Devices;

public record CreateProvisioningCodeResponse(string Code, DateTime ExpiresAt);
