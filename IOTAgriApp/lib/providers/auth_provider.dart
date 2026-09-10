import 'dart:async' show unawaited;
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/token_storage.dart';
import '../core/utils/jwt_decoder.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthResult {
  const AuthResult.success() : errorMessage = null;
  const AuthResult.failure(this.errorMessage);

  final String? errorMessage;
  bool get isSuccess => errorMessage == null;
}

/// Nguon su that duy nhat ve trang thai dang nhap cua toan app. GoRouter
/// lang nghe provider nay (qua refreshListenable) de tu dong dieu huong
/// giua man hinh Auth va khu vuc chinh cua app.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required TokenStorage tokenStorage,
    required ApiClient apiClient,
  })  : _authService = authService,
        _tokenStorage = tokenStorage,
        _apiClient = apiClient {
    _apiClient.onSessionExpired = _handleSessionExpired;
  }

  final AuthService _authService;
  final TokenStorage _tokenStorage;
  final ApiClient _apiClient;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  String? _userId;
  String? _email;
  String? _fullName;

  String? get userId => _userId;
  String? get email => _email;
  String? get fullName => _fullName;

  bool _busy = false;
  bool get busy => _busy;

  /// Goi 1 lan duy nhat luc app khoi dong (SplashScreen). Neu da co
  /// refresh token luu san, chu dong lam moi de dam bao access token
  /// con hieu luc truoc khi vao thang khu vuc chinh.
  Future<void> bootstrap() async {
    final hasSession = await _tokenStorage.hasSession();
    if (!hasSession) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final refreshTokenValue = await _tokenStorage.getRefreshToken();
      final auth = await _authService.refresh(refreshTokenValue!);
      await _tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
        expiresAt: auth.expiresAt,
      );
      _applyClaimsFrom(auth.accessToken);
      _status = AuthStatus.authenticated;
    } catch (_) {
      await _tokenStorage.clear();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<AuthResult> login({required String email, required String password}) async {
    _busy = true;
    notifyListeners();
    try {
      final auth = await _authService.login(email: email, password: password);
      await _tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
        expiresAt: auth.expiresAt,
      );
      _applyClaimsFrom(auth.accessToken);
      _status = AuthStatus.authenticated;
      return const AuthResult.success();
    } on ApiException catch (e) {
      return AuthResult.failure(e.message);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _busy = true;
    notifyListeners();
    try {
      await _authService.register(email: email, password: password, fullName: fullName);
      return const AuthResult.success();
    } on ApiException catch (e) {
      return AuthResult.failure(e.message);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final refreshTokenValue = await _tokenStorage.getRefreshToken();
    if (refreshTokenValue != null) {
      await _authService.logout(refreshTokenValue);
    }
    await _clearLocalSession();
  }

  void _handleSessionExpired() {
    // Duoc ApiClient goi khi refresh token cung da het han/bi thu hoi.
    unawaited(_clearLocalSession());
  }

  Future<void> _clearLocalSession() async {
    await _tokenStorage.clear();
    _userId = null;
    _email = null;
    _fullName = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _applyClaimsFrom(String accessToken) {
    final claims = JwtPayload.tryDecode(accessToken);
    _userId = claims?.userId;
    _email = claims?.email;
    _fullName = claims?.fullName;
  }
}
