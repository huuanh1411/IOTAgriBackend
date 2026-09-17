using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class ProvisioningCodeTests
{
    [Fact]
    public void Generated_code_matches_its_hash_only()
    {
        var code = ProvisioningCode.Create();

        Assert.True(ProvisioningCode.Matches(code, ProvisioningCode.Hash(code)));
        Assert.False(ProvisioningCode.Matches("WRONG-CODE", ProvisioningCode.Hash(code)));
    }

    [Fact]
    public void Code_hashing_is_case_sensitive_after_the_endpoint_normalizes_input()
    {
        var code = "ABCD2345EFGH";

        Assert.True(ProvisioningCode.Matches(code, ProvisioningCode.Hash(code.ToUpperInvariant())));
    }
}
