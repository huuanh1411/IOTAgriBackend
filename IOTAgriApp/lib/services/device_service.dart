import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/device.dart';

/// Goi dung API cua Endpoints/DeviceEndpoints.cs (tat ca deu can Bearer token,
/// va deu duoc backend loc theo OwnerId == user hien tai):
///   GET    /api/devices
///   POST   /api/devices
///   GET    /api/devices/{id}
///   PUT    /api/devices/{id}
///   DELETE /api/devices/{id}
class DeviceService {
  DeviceService(this._client);

  final ApiClient _client;

  Future<List<Device>> list() async {
    try {
      final response = await _client.dio.get<List<dynamic>>('/devices');
      return response.data!
          .map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Device> getById(String id) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/devices/$id');
      return Device.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Luu y: day la LAN DUY NHAT deviceKey (bi mat MQTT) duoc server tra ve.
  Future<NewDeviceResult> create(String name) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/devices',
        data: {'name': name.trim()},
      );
      return NewDeviceResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Device> rename(String id, String newName) async {
    try {
      final response = await _client.dio.put<Map<String, dynamic>>(
        '/devices/$id',
        data: {'name': newName.trim()},
      );
      return Device.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.dio.delete<void>('/devices/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
