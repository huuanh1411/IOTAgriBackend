namespace IOTAgriBackend.Dtos.Admin;

public record AdminUserResponse(string Id, string Email, string FullName, IReadOnlyList<string> Roles);

public record AdminUserPage(IReadOnlyList<AdminUserResponse> Items, int Page, int PageSize, int TotalCount);
