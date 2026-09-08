using System.Security.Claims;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Dashboard;
using IOTAgriBackend.Dtos.Sensors;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Endpoints;

public static class DashboardEndpoints
{
    public static IEndpointRouteBuilder MapDashboardEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api/dashboard")
            .WithTags("Dashboard")
            .RequireAuthorization()
            .MapGet("/overview", GetOverviewAsync);

        return app;
    }

    private static async Task<IResult> GetOverviewAsync(ClaimsPrincipal principal, ApplicationDbContext db)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userId is null)
        {
            return Results.Unauthorized();
        }

        var overview = await db.Devices
            .Where(d => d.OwnerId == userId)
            .OrderByDescending(d => d.CreatedAt)
            .Select(d => new
            {
                Device = d,
                Latest = d.Readings.OrderByDescending(r => r.RecordedAt).FirstOrDefault(),
            })
            .ToListAsync();

        var response = overview.Select(x => new DeviceOverviewResponse(
            x.Device.Id,
            x.Device.Name,
            x.Device.IsOnline,
            x.Device.LastSeenAt,
            x.Latest is null
                ? null
                : new SensorReadingResponse(
                    x.Latest.Id, x.Latest.Temperature, x.Latest.Humidity, x.Latest.Ph, x.Latest.Tds, x.Latest.WaterLevel, x.Latest.RecordedAt)));

        return Results.Ok(response);
    }
}
