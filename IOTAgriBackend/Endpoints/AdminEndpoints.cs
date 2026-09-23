using System.Security.Claims;
using System.Data;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Admin;
using IOTAgriBackend.Dtos.Sensors;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Endpoints;

public static class AdminEndpoints
{
    public static IEndpointRouteBuilder MapAdminEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/admin").WithTags("Admin").RequireAuthorization("AdminOnly");
        group.MapGet("/users", ListUsersAsync);
        group.MapPut("/users/{userId}/role", UpdateRoleAsync);
        group.MapGet("/devices", ListDevicesAsync);
        group.MapGet("/devices/{id:guid}/readings", GetReadingsAsync);
        group.MapPut("/devices/{id:guid}/owner", UpdateDeviceOwnerAsync);
        group.MapGet("/audit-logs", ListAuditLogsAsync);
        return app;
    }

    private static bool HasValidPagination(int page, int pageSize) => page > 0 && pageSize is >= 1 and <= 100;

    private static string? GetUserId(ClaimsPrincipal principal) => principal.FindFirstValue(ClaimTypes.NameIdentifier);

    private static async Task<IResult> ListUsersAsync(UserManager<ApplicationUser> userManager, int page = 1, int pageSize = 50)
    {
        if (!HasValidPagination(page, pageSize)) return Results.BadRequest(new { error = "page must be positive and pageSize must be between 1 and 100." });

        var totalCount = await userManager.Users.CountAsync();
        var users = await userManager.Users.OrderBy(user => user.Email).Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
        var items = new List<AdminUserResponse>(users.Count);
        foreach (var user in users)
            items.Add(new AdminUserResponse(user.Id, user.Email ?? string.Empty, user.FullName, (await userManager.GetRolesAsync(user)).ToList()));

        return Results.Ok(new AdminUserPage(items, page, pageSize, totalCount));
    }

    private static async Task<IResult> UpdateRoleAsync(
        string userId,
        UpdateUserRoleRequest request,
        ClaimsPrincipal principal,
        UserManager<ApplicationUser> userManager,
        ApplicationDbContext db)
    {
        var actorUserId = GetUserId(principal);
        if (actorUserId is null) return Results.Unauthorized();

        await using var transaction = await db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
        var target = await userManager.FindByIdAsync(userId);
        if (target is null) return Results.NotFound();

        var roles = await userManager.GetRolesAsync(target);
        var targetIsAdmin = roles.Contains("Admin");
        var adminCount = targetIsAdmin ? (await userManager.GetUsersInRoleAsync("Admin")).Count : 0;
        var error = AdminRoleRules.Validate(actorUserId, userId, request.Role, targetIsAdmin, adminCount);
        if (error is not null) return Results.BadRequest(new { error });

        if (roles.Count == 1 && roles[0] == request.Role)
            return Results.Ok(new AdminUserResponse(target.Id, target.Email ?? string.Empty, target.FullName, roles.ToList()));

        var removeResult = await userManager.RemoveFromRolesAsync(target, roles.Where(role => role is "User" or "Admin"));
        if (!removeResult.Succeeded) return Results.ValidationProblem(removeResult.Errors.ToDictionary(error => error.Code, error => new[] { error.Description }));

        var addResult = await userManager.AddToRoleAsync(target, request.Role!);
        if (!addResult.Succeeded) return Results.ValidationProblem(addResult.Errors.ToDictionary(error => error.Code, error => new[] { error.Description }));

        db.AdminAuditLogs.Add(new AdminAuditLog
        {
            ActorUserId = actorUserId,
            Action = "role.updated",
            TargetType = "user",
            TargetId = target.Id,
            PreviousValue = string.Join(',', roles.Where(role => role is "User" or "Admin")),
            NewValue = request.Role,
        });
        await db.SaveChangesAsync();
        await transaction.CommitAsync();

        return Results.Ok(new AdminUserResponse(target.Id, target.Email ?? string.Empty, target.FullName, [request.Role!]));
    }

    private static async Task<IResult> ListDevicesAsync(ApplicationDbContext db, int page = 1, int pageSize = 50)
    {
        if (!HasValidPagination(page, pageSize)) return Results.BadRequest(new { error = "page must be positive and pageSize must be between 1 and 100." });

        var totalCount = await db.Devices.CountAsync();
        var items = await db.Devices.OrderByDescending(device => device.CreatedAt).Skip((page - 1) * pageSize).Take(pageSize)
            .Select(device => new AdminDeviceResponse(device.Id, device.Name, device.OwnerId, device.Owner == null ? null : device.Owner.Email, device.IsOnline, device.LastSeenAt, device.CreatedAt))
            .ToListAsync();
        return Results.Ok(new AdminDevicePage(items, page, pageSize, totalCount));
    }

    private static async Task<IResult> GetReadingsAsync(Guid id, ApplicationDbContext db, int take = 50)
    {
        if (!await db.Devices.AnyAsync(device => device.Id == id)) return Results.NotFound();

        var readings = await db.SensorReadings.Where(reading => reading.DeviceId == id).OrderByDescending(reading => reading.RecordedAt)
            .Take(Math.Clamp(take, 1, 500))
            .Select(reading => new SensorReadingResponse(reading.Id, reading.Temperature, reading.Humidity, reading.Ph, reading.Tds, reading.WaterLevel, reading.RecordedAt))
            .ToListAsync();
        return Results.Ok(readings);
    }

    private static async Task<IResult> UpdateDeviceOwnerAsync(
        Guid id,
        UpdateDeviceOwnerRequest request,
        ClaimsPrincipal principal,
        ApplicationDbContext db,
        UserManager<ApplicationUser> userManager)
    {
        var actorUserId = GetUserId(principal);
        if (actorUserId is null) return Results.Unauthorized();
        if (request.OwnerId is not null && string.IsNullOrWhiteSpace(request.OwnerId)) return Results.BadRequest(new { error = "ownerId must be a user ID or null." });

        var device = await db.Devices.FirstOrDefaultAsync(device => device.Id == id);
        if (device is null) return Results.NotFound();

        ApplicationUser? owner = null;
        if (request.OwnerId is not null)
        {
            owner = await userManager.FindByIdAsync(request.OwnerId);
            if (owner is null) return Results.NotFound();
        }

        if (device.OwnerId == request.OwnerId) return Results.Ok(ToDeviceResponse(device, owner));

        var previousOwnerId = device.OwnerId;
        device.OwnerId = request.OwnerId;
        db.AdminAuditLogs.Add(new AdminAuditLog
        {
            ActorUserId = actorUserId,
            Action = "device.owner.updated",
            TargetType = "device",
            TargetId = device.Id.ToString(),
            PreviousValue = previousOwnerId,
            NewValue = request.OwnerId,
        });
        await db.SaveChangesAsync();
        return Results.Ok(ToDeviceResponse(device, owner));
    }

    private static AdminDeviceResponse ToDeviceResponse(Device device, ApplicationUser? owner) =>
        new(device.Id, device.Name, device.OwnerId, owner?.Email, device.IsOnline, device.LastSeenAt, device.CreatedAt);

    private static async Task<IResult> ListAuditLogsAsync(ApplicationDbContext db, int page = 1, int pageSize = 50)
    {
        if (!HasValidPagination(page, pageSize)) return Results.BadRequest(new { error = "page must be positive and pageSize must be between 1 and 100." });

        var totalCount = await db.AdminAuditLogs.CountAsync();
        var items = await db.AdminAuditLogs.OrderByDescending(log => log.CreatedAt).ThenByDescending(log => log.Id)
            .Skip((page - 1) * pageSize).Take(pageSize)
            .Select(log => new AdminAuditLogResponse(log.Id, log.ActorUserId, log.Action, log.TargetType, log.TargetId, log.PreviousValue, log.NewValue, log.CreatedAt))
            .ToListAsync();
        return Results.Ok(new AdminAuditLogPage(items, page, pageSize, totalCount));
    }
}
