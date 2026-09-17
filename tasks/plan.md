# Implementation Plan: Pump Control and Scheduling

## Overview

Add owner-authorized manual pump control and recurring pump schedules for a claimed ESP32 device. Backend sends MQTT commands; device is source of actuator state and reports acknowledgements. Initial scope controls one pump per device.

## Architecture Decisions

- Reuse existing JWT ownership check, `Device`, EF Core, Minimal API, MQTTnet, and firmware. No new package.
- Commands use `devices/{deviceKey}/commands/pump`; device status uses `devices/{deviceKey}/pump-status`. Commands are non-retained and contain an idempotency ID, `on`, and optional duration seconds.
- Schedules store local weekday mask, start time, duration, and IANA time zone. Scheduler converts due runs to UTC. Device defaults pump OFF after reboot and auto-stops after commanded duration.
- Schedule dispatch runs as a separate worker in production. Do not run it in every API replica; local development may run one worker with the API.

## Task List

### Phase 1: Safe manual control

- [ ] Task 1: Add pump command/status contract and persistence
  - Define one pump state record on `Device` and a command/audit record with command ID, requested state, duration, issued time, acknowledgement time, and result.
  - Add EF mapping, migration, and request/response DTOs. Limit duration to a hardware-safe maximum.
  - Acceptance: migration applies; command IDs are unique; no owner can access another owner's device records.
  - Verification: focused tests for validation and ownership query; `dotnet test`; `dotnet build`.
  - Dependencies: None.
  - Files likely touched: `Models/Device.cs`, new pump model/DTO files, `Data/ApplicationDbContext.cs`, `Migrations/`.
  - Estimated scope: Medium (4-5 files).

- [ ] Task 2: Publish manual commands and receive device status
  - Add authorized `POST /api/devices/{id}/pump/commands`; publish only after device ownership validation.
  - Extend MQTT worker to subscribe to pump status, validate topic/device key, and persist acknowledgement/state. Reuse one MQTT client service for readings, commands, and status.
  - Acceptance: valid owner command publishes exact topic/payload; unknown device/status is ignored and logged; acknowledgement updates matching command.
  - Verification: test command payload/topic; manually publish status through Mosquitto and confirm API state changes.
  - Dependencies: Task 1.
  - Files likely touched: `Endpoints/DeviceEndpoints.cs`, `Services/MqttIngestionService.cs`, new service/DTO files, `Program.cs`.
  - Estimated scope: Medium (4-5 files).

- [ ] Task 3: Add ESP32 relay control and acknowledgement
  - Configure relay GPIO and active level in firmware; subscribe to pump command topic after MQTT connect.
  - Deduplicate command IDs, enforce duration timeout locally, default relay OFF on boot/reconnect, and publish pump status after every state change.
  - Acceptance: valid ON command activates relay then stops at duration; duplicate command changes relay once; restart leaves relay OFF.
  - Verification: serial log plus relay/LED test; publish manual MQTT commands; assert command parser against valid and invalid payloads.
  - Dependencies: Task 2.
  - Files likely touched: `firmware/ESP32DeviceSetup/ESP32DeviceSetup.ino`.
  - Estimated scope: Small (1 file).

### Checkpoint: Manual control

- [ ] JWT owner can command a device and see acknowledged state.
- [ ] Pump turns OFF on timeout, invalid command, and firmware restart.
- [ ] `dotnet test` and `dotnet build` pass.

### Phase 2: Recurring schedules

- [ ] Task 4: Add schedule storage and owner API
  - Add schedule model: device ID, enabled, weekday mask, local start time, duration seconds, IANA time zone, and last dispatched occurrence.
  - Add owner-scoped create/list/update/delete endpoints under `/api/devices/{id}/pump-schedules`.
  - Reject invalid weekday mask, time zone, duration, and overlapping schedules for same device.
  - Acceptance: owner CRUD works; invalid/overlapping schedules return validation errors; schedules cannot cross owners.
  - Verification: focused schedule validation tests, including daylight-saving transition cases; `dotnet test`.
  - Dependencies: Task 1.
  - Files likely touched: new schedule model/DTOs, `ApplicationDbContext.cs`, `DeviceEndpoints.cs`, migration.
  - Estimated scope: Medium (5 files).

- [ ] Task 5: Dispatch due schedules once
  - Add one background schedule-dispatch worker. It finds due enabled schedules, atomically records each occurrence as dispatched, then uses manual-command publisher.
  - Publish one duration-bound ON command per occurrence. Log publish failure without marking unsent occurrence complete.
  - Acceptance: due schedule sends one command; polling cannot duplicate same occurrence; disabled schedule sends none.
  - Verification: focused due-time/idempotency tests; local run with short schedule and Mosquitto; `dotnet test`; `dotnet build`.
  - Dependencies: Tasks 2 and 4.
  - Files likely touched: new scheduler service, command publisher, `Program.cs`, tests.
  - Estimated scope: Medium (4-5 files).

### Checkpoint: Complete

- [ ] Manual and scheduled commands share one command path.
- [ ] Device remains safe if backend is unavailable or firmware restarts.
- [ ] API and production worker deployment do not dispatch duplicate schedules.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Relay active level/wiring differs | High | Make pin and active level firmware constants; test with LED before pump. |
| Duplicate MQTT or worker delivery | High | Command IDs, device dedupe, database occurrence uniqueness. |
| Time-zone/DST ambiguity | Medium | Persist IANA zone and occurrence key; test DST cases. |
| API replicas run scheduler | High | Deploy one dedicated worker or use a distributed lock. |

## Open Questions

- Which GPIO pin, relay active level, maximum safe pump runtime, and fail-safe water-level threshold apply?
- Does one device have one pump only, or must hardware support multiple zones now?
- Should schedules execute when device is offline, retry until acknowledged, or be skipped and recorded?
