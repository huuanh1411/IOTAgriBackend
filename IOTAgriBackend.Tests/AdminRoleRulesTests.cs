using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class AdminRoleRulesTests
{
    [Fact]
    public void Rejects_self_changes_and_last_admin_demotion()
    {
        Assert.NotNull(AdminRoleRules.Validate("admin", "admin", "User", true, 2));
        Assert.NotNull(AdminRoleRules.Validate("other", "admin", "User", true, 1));
        Assert.Null(AdminRoleRules.Validate("other", "admin", "User", true, 2));
    }

    [Fact]
    public void Rejects_unknown_role()
    {
        Assert.NotNull(AdminRoleRules.Validate("admin", "user", "Owner", false, 1));
    }
}
