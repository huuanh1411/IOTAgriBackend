using IOTAgriBackend.Models;
using Xunit;

namespace IOTAgriBackend.Tests;

public class PumpSchemaTests
{
    [Fact]
    public void New_command_is_pending_and_has_a_unique_id()
    {
        var first = new PumpCommand();
        var second = new PumpCommand();

        Assert.Equal(PumpCommandStatus.Pending, first.Status);
        Assert.NotEqual(first.Id, second.Id);
    }
}
