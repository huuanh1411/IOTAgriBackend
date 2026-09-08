using System.Security.Claims;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Dashboard;
using IOTAgriBackend.Dtos.Sensors;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Endpoints;

public static class SensorEndpoints
{
    private static readonly HashSet<string> AllowedIntervals = new(StringComparer.OrdinalIgnoreCase)
    {
        "minute", "hour", "day", "week", "month",
    };

    public static IEndpointRouteBuilder MapSensorEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api/devices/{deviceId:guid}/readings")
            .WithTags("Sensors")
            .RequireAuthorization()
            .MapGet("/", GetReadingsAsync);

        app.MapGroup("/api/devices/{deviceId:guid}/readings")
            .WithTags("Sensors")
            .RequireAuthorization()
            .MapGet("/aggregated", GetAggregatedReadingsAsync);

        return app;
    }

    private static async Task<IResult> GetReadingsAsync(
        Guid deviceId,
        ClaimsPrincipal principal,
        ApplicationDbContext db,
        int take = 50)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userId is null)
        {
            return Results.Unauthorized();
        }

        var ownsDevice = await db.Devices.AnyAsync(d => d.Id == deviceId && d.OwnerId == userId);
        if (!ownsDevice)
        {
            return Results.NotFound();
        }

        var readings = await db.SensorReadings
            .Where(r => r.DeviceId == deviceId)
            .OrderByDescending(r => r.RecordedAt)
            .Take(Math.Clamp(take, 1, 500))
            .Select(r => new SensorReadingResponse(r.Id, r.Temperature, r.Humidity, r.Ph, r.Tds, r.WaterLevel, r.RecordedAt))
            .ToListAsync();

        return Results.Ok(readings);
    }

    private static async Task<IResult> GetAggregatedReadingsAsync(
        Guid deviceId,
        ClaimsPrincipal principal,
        ApplicationDbContext db,
        string interval = "hour",
        DateTime? from = null,
        DateTime? to = null)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userId is null)
        {
            return Results.Unauthorized();
        }

        if (!AllowedIntervals.Contains(interval))
        {
            return Results.BadRequest($"Invalid interval. Allowed values: {string.Join(", ", AllowedIntervals)}.");
        }

        var ownsDevice = await db.Devices.AnyAsync(d => d.Id == deviceId && d.OwnerId == userId);
        if (!ownsDevice)
        {
            return Results.NotFound();
        }

        var rangeEnd = to ?? DateTime.UtcNow;
        var rangeStart = from ?? rangeEnd.AddDays(-7);

        // Raw SQL (not raw string concatenation): {n} placeholders become bound Npgsql parameters, so this is not
        // vulnerable to SQL injection despite `interval` being caller-supplied. EF Core's GroupBy translation for
        // this many aggregates over a GroupBy key derived from a mapped scalar function does not translate to SQL.
        var buckets = await db.Database.SqlQueryRaw<AggregatedReadingBucket>(
            """
            SELECT date_trunc({0}, "RecordedAt") AS "BucketStart",
                   AVG("Temperature") AS "AvgTemperature", MIN("Temperature") AS "MinTemperature", MAX("Temperature") AS "MaxTemperature",
                   AVG("Humidity") AS "AvgHumidity", MIN("Humidity") AS "MinHumidity", MAX("Humidity") AS "MaxHumidity",
                   AVG("Ph") AS "AvgPh", MIN("Ph") AS "MinPh", MAX("Ph") AS "MaxPh",
                   AVG("Tds") AS "AvgTds", MIN("Tds") AS "MinTds", MAX("Tds") AS "MaxTds",
                   AVG("WaterLevel") AS "AvgWaterLevel", MIN("WaterLevel") AS "MinWaterLevel", MAX("WaterLevel") AS "MaxWaterLevel",
                   CAST(COUNT(*) AS integer) AS "SampleCount"
            FROM "SensorReadings"
            WHERE "DeviceId" = {1} AND "RecordedAt" >= {2} AND "RecordedAt" <= {3}
            GROUP BY date_trunc({0}, "RecordedAt")
            ORDER BY 1
            """,
            interval, deviceId, rangeStart, rangeEnd)
            .ToListAsync();

        return Results.Ok(buckets);
    }
}
