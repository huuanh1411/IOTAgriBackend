using System;
using IOTAgriBackend.Dtos.Pumps;
using Xunit;

namespace IOTAgriBackend.Tests;

public class PumpCommandRequestTests
{
    [Fact]
    public void On_command_requires_a_bounded_duration()
    {
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), true, null).IsValid(600));
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), true, 601).IsValid(600));
        Assert.True(new PumpCommandRequest(Guid.NewGuid(), true, 600).IsValid(600));
    }

    [Fact]
    public void Off_command_cannot_include_a_duration()
    {
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), false, 1).IsValid(600));
        Assert.True(new PumpCommandRequest(Guid.NewGuid(), false, null).IsValid(600));
    }
}
