# IOTAgriBackend

Backend API for an IoT hydroponics/agriculture monitoring system. Built with ASP.NET Core (.NET 10) and PostgreSQL, designed for eventual deployment to AWS.

## Tech Stack

- **ASP.NET Core 10** (Minimal API)
- **PostgreSQL** via Entity Framework Core (`Npgsql.EntityFrameworkCore.PostgreSQL`)
- **ASP.NET Core Identity** + JWT bearer authentication (access + refresh tokens)
- **MQTT** (MQTTnet) for real-time sensor ingestion from ESP32 devices, via a local Mosquitto broker in dev
- **Swagger / OpenAPI** for API exploration in Development

## Features Implemented So Far

### Auth
- `POST /api/auth/register`, `/login`, `/refresh`, `/logout`
- Email-based accounts, `User`/`Admin` roles, DB-backed refresh token rotation

### Device Management
- `POST /GET /PUT /DELETE /api/devices` (+ `/api/devices/{id}`)
- Each device gets a unique `DeviceKey` used to authenticate its MQTT publishes
- Devices are scoped per owning user

### Sensor Ingestion (MQTT)
- ESP32 devices publish JSON readings to `devices/{deviceKey}/readings` on the MQTT broker
- A background service (`MqttIngestionService`) subscribes, validates the device key, and persists readings
- `GET /api/devices/{deviceId}/readings` — reading history for a device

### Dashboard / Aggregation
- `GET /api/dashboard/overview` — all of a user's devices with latest reading + online status
- `GET /api/devices/{deviceId}/readings/aggregated?interval=hour|day|...` — time-bucketed min/avg/max per metric, computed in PostgreSQL

## Local Development

**Requirements:** .NET 10 SDK, Docker (for PostgreSQL + Mosquitto)

```powershell
# Start dependencies
docker start iotagri-postgres iotagri-mosquitto

# Run the API
cd IOTAgriBackend
dotnet run
```

Swagger UI is available at `/swagger` when running in Development.

### Connecting an ESP32

1. Create a device via `POST /api/devices` (JWT-authenticated) and note the returned `deviceKey`.
2. Point the device's MQTT client at the broker (`host:1883` in dev, no TLS/auth) and publish to:
   ```
   devices/{deviceKey}/readings
   ```
   with a JSON payload like:
   ```json
   { "temperature": 26.5, "humidity": 61.2, "ph": 6.1, "tds": 850, "waterLevel": 42.0 }
   ```

## Planned / Not Yet Implemented

- Pump control & scheduling
- Alerts (threshold-based notifications)
- Dockerfile + CI/CD pipeline
- AWS deployment (ECS Fargate, RDS PostgreSQL, Secrets Manager, CloudWatch)
- AWS IoT Core migration (per-device X.509 certificates in place of the current key-in-topic MQTT auth)
