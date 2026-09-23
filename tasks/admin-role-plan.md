# Implementation Plan: Admin Role Management

## Overview

Add backend-only administration for existing Identity `Admin` role. An administrator can manage user roles, oversee all devices and readings, reassign or revoke device ownership, and review recorded admin actions. No new roles, packages, UI, or generic event framework.

## Architecture Decisions

- Reuse `ApplicationUser`, `UserManager<ApplicationUser>`, seeded `User` and `Admin` roles, JWT role claims, and existing `AdminOnly` policy.
- Add one `/api/admin/users` endpoint group protected by `RequireAuthorization("AdminOnly")`.
- Add one `/api/admin/devices` endpoint group protected by `RequireAuthorization("AdminOnly")`. Reuse existing device and sensor response shapes where possible.
- Role update accepts only `User` or `Admin`. Set target's role by removing existing managed roles, then adding requested role.
- Block self-role changes. Block demotion when target is last administrator.
- Revoke means unassign owner, not delete device. Make `Device.OwnerId` nullable and use a migration so readings and device credentials remain intact.
- Persist only administrator-initiated role and device ownership actions in one `AdminAuditLog` table. Do not build general-purpose audit middleware.
- Token role claims update at next login or refresh. Do not add token revocation for this first slice.

## Task List

### Phase 1: Admin user management

- [x] Task 1: Add admin user list endpoint
  - Add `GET /api/admin/users` returning ID, email, full name, and roles.
  - Protect group with `AdminOnly`; non-administrators receive 403.
  - Acceptance: administrator sees users and roles; `User` cannot access endpoint; no password or refresh-token data is returned.
  - Verification: focused endpoint test for 200 and 403; `dotnet build`.
  - Dependencies: None.
  - Files likely touched: `Endpoints/AdminEndpoints.cs`, `Program.cs`, `Dtos/Auth/AdminUserResponse.cs`, focused test file.
  - Estimated scope: Medium (3-4 files).

- [x] Task 2: Add focused admin audit log
  - Add `AdminAuditLog` with actor user ID, action, target type/ID, prior value, new value, and UTC timestamp.
  - Add EF mapping, migration, and paginated `GET /api/admin/audit-logs` endpoint.
  - Acceptance: only administrators can read logs; log data excludes passwords, tokens, and device keys.
  - Verification: migration applies; focused test confirms authorization and persisted audit record; `dotnet build`.
  - Dependencies: Task 1.
  - Files likely touched: `Models/AdminAuditLog.cs`, `Data/ApplicationDbContext.cs`, `Migrations/`, `Endpoints/AdminEndpoints.cs`, focused test file.
  - Estimated scope: Medium (4-5 files).

### Checkpoint: User administration foundation

- [x] `AdminOnly` protects user and audit endpoints.
- [x] Audit records do not expose secrets.
- [x] Focused tests and `dotnet build` pass.

### Phase 2: Safe role and device administration

- [x] Task 3: Add safe role update endpoint with audit
  - Add `PUT /api/admin/users/{userId}/role` with one role value: `User` or `Admin`.
  - Reject missing user, invalid role, self-change, and demotion of last administrator. Write role change to `AdminAuditLog` in same save.
  - Acceptance: administrator can promote or demote another user; all unsafe requests return 400 or 404; target has exactly requested managed role and one audit record.
  - Verification: focused tests for promotion, demotion, self-change, last-admin guard, and invalid role; `dotnet build`.
  - Dependencies: Task 2.
  - Files likely touched: `Endpoints/AdminEndpoints.cs`, `Dtos/Auth/UpdateUserRoleRequest.cs`, focused test file.
  - Estimated scope: Small (2-3 files).

- [x] Task 4: Add device oversight and ownership actions with audit
  - Add `GET /api/admin/devices`, `GET /api/admin/devices/{id}/readings`, and `PUT /api/admin/devices/{id}/owner`.
  - Ownership update accepts a target user ID to reassign, or null to revoke. Preserve device, readings, commands, and provisioning identity. Write every ownership change to `AdminAuditLog`.
  - Acceptance: administrator can view every device and readings; reassignment changes access; revocation leaves device data intact and inaccessible to former owner; every action is audited.
  - Verification: focused tests for 403, reassignment, revocation, former-owner denial, reading visibility, and audit record; migration applies; `dotnet build`.
  - Dependencies: Tasks 2 and 3.
  - Files likely touched: `Models/Device.cs`, `Data/ApplicationDbContext.cs`, `Migrations/`, `Endpoints/AdminEndpoints.cs`, DTOs and focused test file.
  - Estimated scope: Medium (5 files).

### Checkpoint: Admin API

- [x] `AdminOnly` protects every `/api/admin` endpoint.
- [x] Existing login and refresh include changed role after new token issuance.
- [x] Revoke preserves device and reading records.
- [x] Every role and ownership action has an audit record.
- [x] Focused tests and `dotnet build` pass.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Last administrator removed | High | Count administrators before demotion. |
| Administrator loses own access | High | Reject self-role changes. |
| Revoke deletes device history | High | Set `OwnerId` to null; never delete device. |
| Audit log exposes secret | High | Record identifiers and role/owner values only. |
| Stale JWT role claim | Medium | State clearly: re-login or refresh required. |

## Open Questions

- Should role changes revoke target refresh tokens immediately? Not in initial scope.
- Should reassignment clear provisioning state? Initial scope preserves it.
