import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/devices/device_detail_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/splash/splash_screen.dart';

/// Dinh nghia toan bo dieu huong cua app + "auth guard": GoRouter se tu
/// danh gia lai [redirect] moi khi AuthProvider phat notifyListeners()
/// (nho [refreshListenable]), dam bao nguoi dung luon bi day ve dung
/// man hinh tuong ung voi AuthStatus hien tai - kho co the "lot" vao khu
/// vuc da dang nhap khi chua co token hop le, hay nguoc lai.
GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const AppShell()),
      GoRoute(
        path: '/devices/:id',
        builder: (context, state) => DeviceDetailScreen(deviceId: state.pathParameters['id']!),
      ),
    ],
    redirect: (context, state) {
      final status = authProvider.status;
      final location = state.matchedLocation;
      final isAuthScreen = location == '/login' || location == '/register';
      final isSplash = location == '/splash';

      if (status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      if (status == AuthStatus.unauthenticated) {
        return isAuthScreen ? null : '/login';
      }

      // status == AuthStatus.authenticated
      if (isAuthScreen || isSplash) return '/home';
      return null;
    },
  );
}
