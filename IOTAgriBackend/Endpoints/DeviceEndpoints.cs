using System.Security.Claims;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Devices;
using IOTAgriBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Endpoints;

public static class DeviceEndpoints
{
    public static IEndpointRouteBuilder MapDeviceEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/devices").WithTags("Devices").RequireAuthorization();

        group.MapPost("/", CreateAsync);
        group.MapGet("/", ListAsync);
        group.MapGet("/{id:guid}", GetAsync);
        group.MapPut("/{id:guid}", UpdateAsync);
        group.MapDelete("/{id:guid}", DeleteAsync);

        return app;
    }

    private static string? GetUserId(ClaimsPrincipal principal) =>
        principal.FindFirstValue(ClaimTypes.NameIdentifier);

    private static async Task<IResult> CreateAsync(
        CreateDeviceRequest request,
        ClaimsPrincipal principal,
        ApplicationDbContext db)
    {
        var userId = GetUserId(principal);
        if (userId is null)
        {
            return Results.Unauthorized();
        }

        var device = new Device
        {
            Name = request.Name,
            // URL-safe (no '+' or '/') so the key can be used as an MQTT topic segment.
            DeviceKey = Convert.ToBase64String(System.Security.Cryptography.RandomNumberGenerator.GetBytes(32))
                .Replace('+', '-').Replace('/', '_').TrimEnd('='),
            OwnerId = userId,
        };

        db.Devices.Add(device);
        await db.SaveChangesAsync();

        return Results.Created(
            $"/api/devices/{device.Id}",
            new { device.Id, device.Name, device.DeviceKey, device.CreatedAt });
    }

    private static async Task<IResult> ListAsync(ClaimsPrincipal principal, ApplicationDbContext db)
    {
        var userId = GetUserId(principal);
        if (userId is null)
        {
            return Results.Unauthorized();
        }

        var devices = await db.Devices
            .Where(d => d.OwnerId == userId)
            .OrderByDescending(d => d.CreatedAt)
            .Select(d => new DeviceResponse(d.Id, d.Name, d.IsOnline, d.LastSeenAt, d.CreatedAt))
            .ToListAsync();

        return Results.Ok(devices);
    }

    private static async Task<IResult> GetAsync(Guid id, ClaimsPrincipal principal, ApplicationDbContext db)
    {
        var userId = GetUserId(principal);
        if (userId is null)
        {
            return Results.Unauthorized();
        }

        var device = await db.Devices.FirstOrDefaultAsync(d => d.Id == id && d.OwnerId == userId);
        if (device is null)
        {
            return Results.NotFound();
        }

        return Results.Ok(new DeviceResponse(device.Id, device.Name, device.IsOnline, device.LastSeenAt, device.CreatedAt));
    }

    private static async Task<IResult> UpdateAsync(
        Guid id,
        UpdateDeviceRequest request,
        ClaimsPrincipal principal,
        ApplicationDbContext db)
    {
        var userId = GetUserId(principal);
        if (userId is null)
        {
            return Results.Unauthorized();
        }

        var device = await db.Devices.FirstOrDefaultAsync(d => d.Id == id && d.OwnerId == userId);
        if (device is null)
        {
            return Results.NotFound();
        }

        device.Name = request.Name;
        await db.SaveChangesAsync();

        return Results.Ok(new DeviceResponse(device.Id, device.Name, device.IsOnline, device.LastSeenAt, device.CreatedAt));
    }

    private static async Task<IResult> DeleteAsync(Guid id, ClaimsPrincipal principal, ApplicationDbContext db)
    {
        var userId = GetUserId(principal);
        if (userId is null)
        {
            return Results.Unauthorized();
        }

        var device = await db.Devices.FirstOrDefaultAsync(d => d.Id == id && d.OwnerId == userId);
        if (device is null)
        {
            return Results.NotFound();
        }

        db.Devices.Remove(device);
        await db.SaveChangesAsync();

        return Results.NoContent();
    }
}
