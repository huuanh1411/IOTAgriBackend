# Implementation Plan: Sensor Alert Delivery

## Overview

Add owner-visible alerts when a device reports excessive temperature or a low irrigation-water source level. The first delivery channel is the authenticated dashboard/API. Email, push, SMS, and automatic pump control remain out of scope.

## Architecture Decisions

- Reuse the MQTT reading path, `SensorReading`, `Device` ownership, EF Core, and Minimal API. No package, broker topic, or second worker.
- Treat `WaterLevel` as reservoir percentage. A reading triggers at `temperature >= highTemperatureC` or `waterLevel <= lowWaterLevelPercent`.
- Store per-device, nullable thresholds. `null` disables that alert type until the owner configures it. This avoids uncalibrated default thresholds on real hardware.
- Persist one active alert per device and type. Later unsafe readings update nothing; a safe reading resolves it. This prevents a database row and dashboard alert on every MQTT sample.
- Expose owner-scoped `GET`/`PUT /api/devices/{id}/alert-settings`, paginated `GET /api/devices/{id}/alerts`, and additive active-alert data in `GET /api/dashboard/overview`.
- An alert reflects a sensor condition only. Low-water automatic pump stop is separate safety-control work, not part of delivery.

## API Contract

### Alert settings

`GET /api/devices/{id}/alert-settings`

```json
{
  "highTemperatureC": 35.0,
  "lowWaterLevelPercent": 20.0
}
```

`PUT /api/devices/{id}/alert-settings`

```json
{
  "highTemperatureC": 35.0,
  "lowWaterLevelPercent": 20.0
}
```

Each field accepts `null` to disable its alert. Reject non-finite values and water-level thresholds outside `0..100` with the repository's `400 { error }` response. Return `401` without a token and `404` for a device not owned by the caller.

### Alert history and dashboard

`GET /api/devices/{id}/alerts?status=active&page=1&pageSize=50` returns a paginated newest-first list. Each item has ID, type (`HIGH_TEMPERATURE` or `LOW_WATER_LEVEL`), measured value, threshold, triggered UTC time, and optional resolved UTC time.

`GET /api/dashboard/overview` adds optional `activeAlerts` to each existing device item. Existing fields and routes remain unchanged.

## Task List

### Phase 1: Contract and persistence

- [x] Task 1: Add alert settings and alert record
  - Add nullable per-device temperature and water-level thresholds.
  - Add `DeviceAlert` persistence for type, measured value, threshold, triggered time, and resolved time. Enforce one unresolved alert per device/type with a PostgreSQL partial unique index.
  - Add typed request/response DTOs and owner-scoped settings `GET`/`PUT` endpoints with boundary validation.
  - Acceptance: an owner can configure or disable each threshold; another user gets `404`; migration prevents duplicate active alert types.
  - Verification: focused threshold-validation/schema tests; apply migration; `dotnet test`; `dotnet build`.
  - Dependencies: None.
  - Files likely touched: `Models/Device.cs`, new alert model/DTOs, `ApplicationDbContext.cs`, `DeviceEndpoints.cs`, `Migrations/`.
  - Estimated scope: Medium (5 files plus generated migration artifacts).

### Phase 2: Detect and deliver

- [x] Task 2: Evaluate alerts during MQTT reading ingestion
  - After storing a valid reading, evaluate only configured thresholds in `MqttIngestionService`'s existing database scope.
  - Create an active alert only on a normal-to-unsafe transition; resolve its matching active alert once the value returns to the safe side. Use the unique index as the duplicate-delivery guard.
  - Keep alert evaluation as a small pure helper with focused tests for threshold boundaries, disabled thresholds, and recovery.
  - Acceptance: repeated unsafe readings create one active alert; exact threshold values alert; recovery resolves it; unknown-device readings still create no records.
  - Verification: focused alert-rule tests plus MQTT ingestion test; manually publish readings and inspect alert API; `dotnet test`; `dotnet build`.
  - Dependencies: Task 1.
  - Files likely touched: `Services/MqttIngestionService.cs`, one alert-rule helper, focused test file.
  - Estimated scope: Small (3 files).

- [x] Task 3: Expose active and historical alerts
  - Add paginated owner-only alert history endpoint with validated `status`, page, and page-size query parameters.
  - Add each device's active alerts to the existing dashboard overview response without removing or renaming current fields.
  - Acceptance: users see only their own alerts; default list is newest-first and bounded; dashboard exposes active alerts and clears them after recovery.
  - Verification: focused ownership/pagination tests; authenticated API check for settings, active alerts, resolution, and dashboard; `dotnet test`; `dotnet build`.
  - Dependencies: Tasks 1 and 2.
  - Files likely touched: `Endpoints/DeviceEndpoints.cs`, `Endpoints/DashboardEndpoints.cs`, dashboard/alert DTOs, focused test file.
  - Estimated scope: Medium (4 files).

### Checkpoint: Dashboard/API delivery

- [x] Configured high temperature and low reservoir level appear once per active condition.
- [x] Safe readings resolve matching alerts.
- [x] Owner isolation, validation, pagination, migration, tests, and build pass.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Reservoir sensor scale differs from percentage | High | Confirm firmware sends `0..100` before enabling low-water thresholds. |
| MQTT redelivery creates duplicate alerts | Medium | Partial unique index on unresolved device/type pairs. |
| Thresholds unsuitable for a crop or sensor | Medium | Per-device nullable threshold controls; no hard-coded safety default. |
| User expects a phone notification | Medium | Dashboard/API only in this phase; add email/push delivery after this contract is proven. |

## Deferred

- Email, push, SMS, WebSocket, and external notification providers.
- Acknowledgement/muting, escalation, notification preferences, and delivery retries.
- Automatic pump stop or restart decisions based on low reservoir level.

## Open Questions

- Does ESP32 report reservoir level as a calibrated `0..100` percentage?
- What high-temperature and low-reservoir thresholds should each device start with?

## Verification Status

- Automated: 22 tests pass; production build has 0 warnings/errors; EF reports no pending model changes.
- Docker E2E: authenticated owner API flow and QoS 1 MQTT readings created two active alerts, deduplicated repeat unsafe readings, resolved both after recovery, and cleared the dashboard's active alerts.
