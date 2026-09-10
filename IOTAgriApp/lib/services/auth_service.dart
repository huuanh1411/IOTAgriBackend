import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/auth_response.dart';
import '../models/user_summary.dart';

/// Goi dung API cua Endpoints/AuthEndpoints.cs:
///   POST /api/auth/register
///   POST /api/auth/login
///   POST /api/auth/refresh
///   POST /api/auth/logout   (can Bearer token)
class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<UserSummary> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'fullName': fullName.trim(),
        },
      );
      return UserSummary.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );
      return AuthResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AuthResponse> refresh(String refreshToken) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return AuthResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Best-effort: neu request that bai (mat mang, token da het han o server...)
  /// van khong sao vi phia client se tu xoa session cuc bo ngay sau do.
  Future<void> logout(String refreshToken) async {
    try {
      await _client.dio.post<void>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException {
      // bo qua loi, van tiep tuc dang xuat cuc bo
    }
  }
}
