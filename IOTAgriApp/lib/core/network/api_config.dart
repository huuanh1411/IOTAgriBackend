/// Cau hinh dia chi API backend (IOTAgriBackend).
///
/// Co the override luc build/run bang:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5261/api
///
/// Mac dinh tro ve dev server chay tren may host, theo dung port trong
/// `Properties/launchSettings.json` cua backend (http://localhost:5261).
///
/// Ghi chu quan trong ve emulator/thiet bi that:
/// - Android Emulator: dung 10.0.2.2 de tro ve localhost cua may host (mac dinh ben duoi).
/// - iOS Simulator: dung http://localhost:5261/api.
/// - Thiet bi that (dien thoai that): dung dia chi IP LAN cua may chay backend,
///   vi du http://192.168.1.10:5261/api (may tinh va dien thoai phai cung mang wifi).
class ApiConfig {
  ApiConfig._();

  static const String _defaultBaseUrl = 'http://10.0.2.2:5261/api';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static const Duration connectTimeout = Duration(seconds: 12);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
