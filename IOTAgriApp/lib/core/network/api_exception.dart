import 'package:dio/dio.dart';

/// Loi API duoc chuan hoa tu cac dang response ma backend IOTAgriBackend
/// tra ve, cu the:
///  - Results.ValidationProblem(...)  -> { "errors": { "Code": ["mo ta"] } }
///  - Results.Conflict(new { message })-> { "message": "..." }
///  - Results.BadRequest("chuoi")      -> body la 1 chuoi JSON thuan
///  - Results.Unauthorized() / NotFound() -> khong co body
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;

  factory ApiException.fromDioException(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (data is String && data.trim().isNotEmpty) {
      return ApiException(data, statusCode: statusCode);
    }

    if (data is Map<String, dynamic>) {
      if (data['errors'] is Map) {
        final rawErrors = (data['errors'] as Map).map(
          (key, value) => MapEntry(
            key.toString(),
            (value as List).map((e) => e.toString()).toList(),
          ),
        );
        final flatMessage = rawErrors.values.expand((v) => v).join('\n');
        return ApiException(
          flatMessage.isEmpty ? 'Du lieu khong hop le.' : flatMessage,
          statusCode: statusCode,
          fieldErrors: rawErrors,
        );
      }
      if (data['message'] is String) {
        return ApiException(data['message'] as String, statusCode: statusCode);
      }
      if (data['detail'] is String) {
        return ApiException(data['detail'] as String, statusCode: statusCode);
      }
      if (data['title'] is String) {
        return ApiException(data['title'] as String, statusCode: statusCode);
      }
    }

    switch (statusCode) {
      case 401:
        return ApiException('Phien dang nhap da het han, vui long dang nhap lai.', statusCode: 401);
      case 404:
        return ApiException('Khong tim thay du lieu.', statusCode: 404);
      case 409:
        return ApiException('Du lieu bi trung, vui long kiem tra lai.', statusCode: 409);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Ket noi toi may chu qua han, vui long thu lai.', statusCode: statusCode);
      case DioExceptionType.connectionError:
        return ApiException(
          'Khong the ket noi toi may chu. Kiem tra dia chi API va mang internet.',
          statusCode: statusCode,
        );
      default:
        return ApiException('Da co loi xay ra, vui long thu lai.', statusCode: statusCode);
    }
  }

  @override
  String toString() => message;
}
