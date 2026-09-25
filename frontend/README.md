# Hệ Thống Giám Sát Nông Thông Minh - Flutter App

Ứng dụng di động Flutter cho hệ thống giám sát nông nghiệp IoT, kết nối với backend ASP.NET Core.

## 🚀 Tính Năng

- 🔐 **Xác thực người dùng**: Đăng ký, đăng nhập với JWT
- 📊 **Dashboard tổng quan**: Xem trạng thái tất cả thiết bị
- 📱 **Quản lý thiết bị**: Thêm, sửa, xóa thiết bị IoT
- 🌡️ **Giám sát cảm biến**: Nhiệt độ, độ ẩm, pH, TDS, mực nước
- 💧 **Điều khiển bơm**: Bật/tắt bơm thủ công
- ⚠️ **Cảnh báo**: Thông báo khi các chỉ số vượt ngưỡng
- 📈 **Lịch sử dữ liệu**: Xem dữ liệu cảm biến theo thời gian

## 🛠️ Công Nghệ

- **Framework**: Flutter 3.10+
- **Language**: Dart
- **State Management**: Provider
- **HTTP Client**: http package
- **Secure Storage**: flutter_secure_storage
- **Date Formatting**: intl
- **Charts**: fl_chart

## 📦 Cài Đặt

1. Cài đặt dependencies:
```bash
flutter pub get
```

2. Cấu hình môi trường:
```bash
# Tạo file .env trong thư mục gốc
echo "API_BASE_URL=http://localhost:8080" > .env
```

## 🏃 Chạy Ứng Dụng

### Development mode:
```bash
flutter run
```

### Build cho Android:
```bash
flutter build apk
```

### Build cho iOS:
```bash
flutter build ios
```

## 📁 Cấu Trúc Thư Mục

```
lib/
├── main.dart                 # Entry point của ứng dụng
├── models/                   # Data models
│   ├── user.dart
│   ├── device.dart
│   ├── sensor_reading.dart
│   ├── device_alert.dart
│   ├── pump_command.dart
│   └── pump_schedule.dart
├── services/                 # API services
│   └── api_service.dart
├── providers/                # State management
│   └── auth_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   └── devices/
│       ├── devices_screen.dart
│       └── device_detail_screen.dart
├── widgets/                  # Reusable widgets
├── utils/                    # Utility functions
└── constants/                # Constants
    └── api_constants.dart
```

## 🔗 Kết Nối API

Ứng dụng kết nối với backend ASP.NET Core thông qua REST API:

- **Authentication**: `/api/auth/*`
- **Devices**: `/api/devices/*`
- **Dashboard**: `/api/dashboard/*`
- **Sensor Readings**: `/api/devices/{id}/readings`
- **Pump Control**: `/api/devices/{id}/pump/*`
- **Alerts**: `/api/devices/{id}/alerts`

## 🎨 Giao Diện

- ✅ Tiếng Việt có dấu
- ✅ Font Arial
- ✅ Material Design
- ✅ Responsive design
- ✅ Theme màu xanh lá cây

## 🔐 Xác Thực

Sử dụng JWT token với refresh token rotation:
- Access token: 15 phút
- Refresh token: 7 ngày
- Tự động refresh khi access token hết hạn
- Lưu trữ an toàn với flutter_secure_storage

## 📱 Tính Năng Chính

### Dashboard
- Trang chủ với thông tin chào mừng
- Điều hướng nhanh đến các tính năng
- Menu bottom navigation

### Quản lý Thiết Bị
- Danh sách tất cả thiết bị
- Thêm thiết bị mới
- Xem trạng thái online/offline
- Điều hướng đến chi tiết thiết bị

### Chi tiết Thiết Bị
- Tổng quan chỉ số cảm biến
- Lịch sử dữ liệu cảm biến
- Điều khiển bơm thủ công
- Lịch sử lệnh bơm
- Xem cảnh báo

## 🚀 Triển Khai

### Environment Variables:
- `API_BASE_URL`: URL của backend API (mặc định: http://localhost:8080)

### Build Commands:
```bash
flutter build apk    # Build Android APK
flutter build ios    # Build iOS
flutter build web    # Build web version
```

## 📝 Ghi Chú

- Ứng dụng được thiết kế để hoạt động với backend ASP.NET Core
- Tất cả text hiển thị bằng tiếng Việt có dấu
- Sử dụng font Arial theo yêu cầu
- Responsive design cho các kích thước màn hình khác nhau
- Hỗ trợ Android, iOS, Web, Windows, macOS, Linux

## 🔧 Cấu Hình

### Cấu hình API URL:
Mặc định ứng dụng sử dụng `http://localhost:8080`. Để thay đổi:

1. Cập nhật trong `lib/constants/api_constants.dart`
2. Hoặc sử dụng environment variable khi build:
```bash
flutter run --dart-define=API_BASE_URL=https://your-api-url.com
```

### Cấu hình Security:
- Tokens được lưu trữ an toàn với flutter_secure_storage
- Tự động refresh token khi hết hạn
- Xử lý lỗi session expired

## 🐛 Troubleshooting

### Lỗi kết nối API:
- Kiểm tra URL API trong constants
- Đảm bảo backend đang chạy
- Kiểm tra kết nối mạng

### Lỗi build:
- Chạy `flutter clean`
- Chạy `flutter pub get`
- Kiểm tra phiên bản Flutter SDK

## 📄 License

Proprietary - All rights reserved