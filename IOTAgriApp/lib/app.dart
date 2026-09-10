import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/network/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/device_provider.dart';
import 'providers/nav_tab_provider.dart';
import 'providers/sensor_provider.dart';
import 'routes/app_router.dart';
import 'services/auth_service.dart';
import 'services/dashboard_service.dart';
import 'services/device_service.dart';
import 'services/sensor_service.dart';

/// Noi "lap rap" toan bo dependency cua app theo mo hinh don gian, thu
/// cong (khong dung service locator/DI framework rieng de de doc, de
/// theo doi vong doi cua tung doi tuong):
///
///   TokenStorage -> ApiClient -> *Service -> *Provider -> UI
///
/// GoRouter va AuthProvider chi duoc khoi tao MOT LAN DUY NHAT trong
/// initState (khong phai trong build/Consumer) - GoRouter tu dong huong
/// theo AuthProvider qua refreshListenable, khong can tao lai router moi
/// khi trang thai dang nhap thay doi (tranh mat ngan xep dieu huong).
class AgriSenseApp extends StatefulWidget {
  const AgriSenseApp({super.key});

  @override
  State<AgriSenseApp> createState() => _AgriSenseAppState();
}

class _AgriSenseAppState extends State<AgriSenseApp> {
  late final TokenStorage _tokenStorage;
  late final ApiClient _apiClient;

  late final AuthProvider _authProvider;
  late final DeviceProvider _deviceProvider;
  late final DashboardProvider _dashboardProvider;
  late final SensorProvider _sensorProvider;
  late final NavTabProvider _navTabProvider;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _tokenStorage = TokenStorage();
    _apiClient = ApiClient(_tokenStorage);

    _authProvider = AuthProvider(
      authService: AuthService(_apiClient),
      tokenStorage: _tokenStorage,
      apiClient: _apiClient,
    );
    _deviceProvider = DeviceProvider(DeviceService(_apiClient));
    _dashboardProvider = DashboardProvider(DashboardService(_apiClient));
    _sensorProvider = SensorProvider(SensorService(_apiClient));
    _navTabProvider = NavTabProvider();

    _router = buildRouter(_authProvider);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _deviceProvider.dispose();
    _dashboardProvider.dispose();
    _sensorProvider.dispose();
    _navTabProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _deviceProvider),
        ChangeNotifierProvider.value(value: _dashboardProvider),
        ChangeNotifierProvider.value(value: _sensorProvider),
        ChangeNotifierProvider.value(value: _navTabProvider),
      ],
      child: MaterialApp.router(
        title: 'AgriSense',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
