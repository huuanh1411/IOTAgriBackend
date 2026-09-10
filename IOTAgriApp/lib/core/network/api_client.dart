import 'dart:async';
import 'package:dio/dio.dart';
import '../../models/auth_response.dart';
import 'api_config.dart';
import 'token_storage.dart';

/// Lop bao boc Dio duy nhat cua toan app. Chiu trach nhiem:
///  1. Tu dong gan header `Authorization: Bearer <accessToken>` cho moi
///     request (tru cac endpoint auth khong can token).
///  2. Khi nhan 401 tu server, tu dong goi POST /api/auth/refresh (dung
///     dung hop dong RefreshRequest/AuthResponse cua backend), luu token
///     moi va PHAT LAI request cu mot cach trong suot.
///  3. Neu refresh that bai (refresh token het han/roi), don sach phien
///     va bao cho AuthProvider qua callback [onSessionExpired] de dieu
///     huong nguoi dung ve man hinh dang nhap.
///  4. Dong bo voi co che xoay vong refresh token cua backend (moi lan
///     refresh, backend thu hoi token cu va phat token moi) bang cach
///     luon ghi de refresh token moi nhat vao storage.
class ApiClient {
  ApiClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: 'application/json',
      ),
    );

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  final TokenStorage _tokenStorage;
  late final Dio _dio;
  late final Dio _refreshDio;

  /// Duoc AuthProvider gan luc khoi tao app.
  void Function()? onSessionExpired;

  Completer<bool>? _refreshCompleter;

  Dio get dio => _dio;

  bool _isAuthFreePath(String path) =>
      path.contains('/auth/login') ||
      path.contains('/auth/register') ||
      path.contains('/auth/refresh');

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isAuthFreePath(options.path)) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    final requestOptions = error.requestOptions;
    final statusCode = error.response?.statusCode;
    final alreadyRetried = requestOptions.extra['retriedAfterRefresh'] == true;

    final shouldTryRefresh =
        statusCode == 401 && !_isAuthFreePath(requestOptions.path) && !alreadyRetried;

    if (!shouldTryRefresh) {
      handler.next(error);
      return;
    }

    final refreshed = await _refreshToken();
    if (!refreshed) {
      await _tokenStorage.clear();
      onSessionExpired?.call();
      handler.next(error);
      return;
    }

    try {
      final newToken = await _tokenStorage.getAccessToken();
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
      requestOptions.extra = {...requestOptions.extra, 'retriedAfterRefresh': true};
      final retryResponse = await _dio.fetch(requestOptions);
      handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Dam bao chi co MOT request refresh dang bay o mot thoi diem, du co
  /// nhieu request khac cung nhan 401 song song (tranh dua nhau refresh
  /// va lam roi ren co che xoay vong token cua backend).
  Future<bool> _refreshToken() {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    final completer = Completer<bool>();
    _refreshCompleter = completer;

    () async {
      try {
        final refreshTokenValue = await _tokenStorage.getRefreshToken();
        if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
          completer.complete(false);
          return;
        }

        final response = await _refreshDio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refreshToken': refreshTokenValue},
        );

        final auth = AuthResponse.fromJson(response.data!);
        await _tokenStorage.saveTokens(
          accessToken: auth.accessToken,
          refreshToken: auth.refreshToken,
          expiresAt: auth.expiresAt,
        );
        completer.complete(true);
      } catch (_) {
        completer.complete(false);
      } finally {
        _refreshCompleter = null;
      }
    }();

    return completer.future;
  }
}
