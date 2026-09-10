import 'dart:convert';

/// Giai ma (khong xac thuc chu ky) phan payload cua JWT access token de
/// doc cac claim hien thi (sub, email, fullName) - TokenService.cs ben
/// backend nhung cac claim nay vao token luc dang nhap:
///   Sub -> "sub", Email -> "email", custom claim "fullName" -> "fullName".
/// Viec xac thuc chu ky JWT la trach nhiem cua server, client chi doc de
/// hien thi UI, khong dung ket qua nay cho quyet dinh bao mat nao khac.
class JwtPayload {
  const JwtPayload({this.userId, this.email, this.fullName, this.expiresAt});

  final String? userId;
  final String? email;
  final String? fullName;
  final DateTime? expiresAt;

  static JwtPayload? tryDecode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      var payloadSegment = parts[1];
      payloadSegment = payloadSegment.padRight(
        payloadSegment.length + (4 - payloadSegment.length % 4) % 4,
        '=',
      );
      final decodedBytes = base64Url.decode(payloadSegment);
      final map = jsonDecode(utf8.decode(decodedBytes)) as Map<String, dynamic>;

      DateTime? exp;
      final expClaim = map['exp'];
      if (expClaim is int) {
        exp = DateTime.fromMillisecondsSinceEpoch(expClaim * 1000, isUtc: true).toLocal();
      }

      return JwtPayload(
        userId: map['sub'] as String?,
        email: map['email'] as String?,
        fullName: map['fullName'] as String?,
        expiresAt: exp,
      );
    } catch (_) {
      return null;
    }
  }
}
