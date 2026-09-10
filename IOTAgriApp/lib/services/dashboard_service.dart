import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/device_overview.dart';

/// Goi dung API cua Endpoints/DashboardEndpoints.cs:
///   GET /api/dashboard/overview
class DashboardService {
  DashboardService(this._client);

  final ApiClient _client;

  Future<List<DeviceOverview>> getOverview() async {
    try {
      final response = await _client.dio.get<List<dynamic>>('/dashboard/overview');
      return response.data!
          .map((e) => DeviceOverview.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
