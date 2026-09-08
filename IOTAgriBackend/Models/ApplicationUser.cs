using Microsoft.AspNetCore.Identity;

namespace IOTAgriBackend.Models;

public class ApplicationUser : IdentityUser
{
    public string FullName { get; set; } = string.Empty;

    public ICollection<Device> Devices { get; set; } = new List<Device>();
}
