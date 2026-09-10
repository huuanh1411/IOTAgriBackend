import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Luu tru access token / refresh token an toan tren thiet bi
/// (Keystore tren Android, Keychain tren iOS) - khong bao gio dung
/// SharedPreferences thuan cho du lieu nhay cam nay.
class TokenStorage {
  TokenStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'iotagri.accessToken';
  static const _kRefreshToken = 'iotagri.refreshToken';
  static const _kExpiresAt = 'iotagri.expiresAt';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
      _storage.write(key: _kExpiresAt, value: expiresAt.toIso8601String()),
    ]);
  }

  /// Cap nhat rieng access token (dung sau khi refresh thanh cong ma
  /// backend giu nguyen refresh token - hien tai backend luon xoay vong
  /// ca hai nen ham nay chi la tien ich du phong).
  Future<void> updateAccessToken(String accessToken, DateTime expiresAt) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kExpiresAt, value: expiresAt.toIso8601String()),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<DateTime?> getExpiresAt() async {
    final raw = await _storage.read(key: _kExpiresAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<bool> hasSession() async {
    final refresh = await getRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kExpiresAt),
    ]);
  }
}
