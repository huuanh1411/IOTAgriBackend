# AgriSense (Flutter) — Frontend cho IOTAgriBackend

Ứng dụng Flutter đồng hành với backend **IOTAgriBackend** (ASP.NET Core Minimal API).
Toàn bộ logic gọi API, tên field, quy tắc validate, và luồng xác thực được xây
**khớp 1-1** với mã nguồn backend đã có — không giả định thêm endpoint nào
backend chưa cung cấp.

## 1. Vì sao chọn kiến trúc này

| Lớp | Vai trò | Vị trí |
|---|---|---|
| `core/network` | `ApiClient` (Dio) gắn JWT tự động, tự refresh khi 401, `TokenStorage` lưu token an toàn (Keystore/Keychain) | `lib/core/network` |
| `models` | Map 1-1 JSON (camelCase) mà backend trả về | `lib/models` |
| `services` | Gọi đúng từng endpoint (1 service / 1 nhóm Endpoints ở backend) | `lib/services` |
| `providers` | State management (Provider/ChangeNotifier) | `lib/providers` |
| `screens` + `widgets` | Giao diện, theme nông nghiệp/thủy canh (xanh lá) | `lib/screens`, `lib/widgets` |
| `routes` | `go_router` + auth guard tự động điều hướng theo trạng thái đăng nhập | `lib/routes` |

## 2. Mapping API ⇆ code (để bạn đối chiếu khi backend thay đổi)

| Backend endpoint | Service method | Ghi chú |
|---|---|---|
| `POST /api/auth/register` | `AuthService.register` | Không trả token — sau khi đăng ký, app điều hướng sang màn Đăng nhập |
| `POST /api/auth/login` | `AuthService.login` | Lưu access+refresh token vào `flutter_secure_storage` |
| `POST /api/auth/refresh` | `AuthService.refresh` | Gọi tự động bởi `ApiClient` khi gặp 401, và lúc khởi động app (`AuthProvider.bootstrap`) |
| `POST /api/auth/logout` | `AuthService.logout` | Best-effort, luôn xoá session cục bộ dù request lỗi |
| `GET/POST/PUT/DELETE /api/devices...` | `DeviceService` | `POST` trả về `deviceKey` **duy nhất 1 lần** → hiển thị qua `DeviceKeyDialog` |
| `GET /api/devices/{id}/readings` | `SensorService.getReadings` | `take` được clamp 1..500 giống backend |
| `GET /api/devices/{id}/readings/aggregated` | `SensorService.getAggregated` | `interval` giới hạn đúng 5 giá trị backend cho phép: `minute/hour/day/week/month` |
| `GET /api/dashboard/overview` | `DashboardService.getOverview` | `DashboardProvider` tự poll lại mỗi 15s |

**Về đăng nhập & thông tin người dùng**: backend chưa có endpoint `GET /me`,
nên app giải mã (không xác thực chữ ký, chỉ đọc) claim `sub`/`email`/`fullName`
ngay trong access token JWT để hiển thị ở màn "Cá nhân" — xem
`lib/core/utils/jwt_decoder.dart`.

**Về trạng thái online**: hiện `Device.IsOnline` bên backend chỉ được set
`true` khi có dữ liệu MQTT tới, **chưa có cơ chế set lại `false`** khi thiết
bị ngừng gửi lâu (đã nêu ở phần review backend trước đó). App vẫn hiển thị
đúng theo dữ liệu backend trả về, đồng thời luôn kèm "lần cuối nhận dữ liệu"
(`lastSeenAt`) để người dùng tự đối chiếu — xem `lib/widgets/online_badge.dart`.

## 3. Cài đặt & chạy

### Bước 1 — Lấy khung project Flutter đầy đủ (android/, ios/...)

Thư mục này hiện chỉ chứa `lib/`, `pubspec.yaml` — **chưa có** thư mục nền
tảng `android/`, `ios/` (những phần đó do Flutter CLI sinh ra, phụ thuộc
máy/SDK của bạn, nên không tạo sẵn ở đây). Trong thư mục `iotagri_app/`, chạy:

```bash
flutter create . --project-name iotagri_app --org com.yourcompany
```

Lệnh này sẽ tạo `android/`, `ios/`, v.v. mà **không đụng tới** `lib/` và
`pubspec.yaml` đã có sẵn (Flutter chỉ bổ sung phần còn thiếu).

### Bước 2 — Cài dependency

```bash
flutter pub get
```

### Bước 3 — Cấu hình địa chỉ backend

Mặc định app trỏ tới `http://10.0.2.2:5261/api` (10.0.2.2 = localhost của máy
host khi chạy Android Emulator, cổng 5261 lấy đúng từ
`IOTAgriBackend/Properties/launchSettings.json`).

- **Android Emulator**: giữ mặc định, chỉ cần `dotnet run` backend ở máy host.
- **iOS Simulator**:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://localhost:5261/api
  ```
- **Điện thoại thật** (cùng mạng Wi-Fi với máy chạy backend):
  ```bash
  flutter run --dart-define=API_BASE_URL=http://<IP-LAN-cua-may-chay-backend>:5261/api
  ```

### Bước 4 — Cho phép HTTP (cleartext) khi chạy Android ở chế độ dev

Backend dev hiện chạy HTTP thuần (không TLS) ở cổng 5261. Từ Android 9 trở
lên, cleartext traffic bị chặn mặc định. Sau khi chạy `flutter create .`:

1. Copy `android_config_notes/network_security_config.xml` vào
   `android/app/src/main/res/xml/network_security_config.xml`.
2. Trong `android/app/src/main/AndroidManifest.xml`, thẻ `<application>`
   thêm:
   ```xml
   android:networkSecurityConfig="@xml/network_security_config"
   android:usesCleartextTraffic="true"
   ```

(iOS Simulator không cần bước này vì App Transport Security cho phép
localhost mặc định trong môi trường debug.)

### Bước 5 — Chạy app

```bash
flutter run
```

## 4. Cấu trúc thư mục

```
lib/
  core/
    network/   ApiClient, TokenStorage, ApiConfig, ApiException
    theme/     Màu sắc + ThemeData (xanh lá nông nghiệp)
    utils/     sensor_metric.dart (map field cảm biến dùng chung),
               jwt_decoder.dart, formatters.dart, validators.dart
  models/      Device, SensorReading, AggregatedBucket, DeviceOverview...
  services/    AuthService, DeviceService, SensorService, DashboardService
  providers/   AuthProvider, DeviceProvider, DashboardProvider,
               SensorProvider, NavTabProvider
  routes/      app_router.dart (go_router + auth guard)
  screens/     splash, auth (login/register), shell (bottom nav),
               dashboard, devices (list/detail/create/key-dialog), profile
  widgets/     AppButton, AppTextField, DeviceCard, MetricTile,
               AggregatedChart (fl_chart), IntervalSelector, MetricSelector...
```

## 5. Những điều CHƯA làm (đồng bộ với giới hạn hiện tại của backend)

- Không có push notification / cảnh báo ngưỡng cảm biến — backend chưa có
  tính năng này.
- Không có màn hình Admin — backend có khai báo policy `AdminOnly` nhưng
  chưa gắn vào endpoint nào.
- Không có tính năng "tạo lại Device Key" — backend chưa có endpoint này;
  muốn đổi key hiện phải xoá và tạo thiết bị mới.
- Dashboard dùng polling (15s) thay vì real-time, vì backend chưa có
  WebSocket/SignalR để đẩy dữ liệu MQTT xuống client.

Khi backend bổ sung các tính năng trên, chỉ cần thêm method tương ứng vào
`services/`, state vào `providers/`, và UI vào `screens/`/`widgets/` theo
đúng pattern đã có — không cần đổi kiến trúc.
