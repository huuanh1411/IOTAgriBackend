import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/aggregated_bucket.dart';
import '../models/sensor_reading.dart';

/// Goi dung API cua Endpoints/SensorEndpoints.cs:
///   GET /api/devices/{deviceId}/readings?take=
///   GET /api/devices/{deviceId}/readings/aggregated?interval=&from=&to=
class SensorService {
  SensorService(this._client);

  final ApiClient _client;

  /// [take] duoc backend Math.Clamp trong khoang 1..500 - client cung
  /// gioi han truoc de tranh goi API voi gia tri vo nghia.
  Future<List<SensorReading>> getReadings(String deviceId, {int take = 50}) async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        '/devices/$deviceId/readings',
        queryParameters: {'take': take.clamp(1, 500)},
      );
      return response.data!
          .map((e) => SensorReading.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// [interval] phai la 1 trong: minute, hour, day, week, month
  /// (dung theo SensorEndpoints.AllowedIntervals ben backend).
  Future<List<AggregatedBucket>> getAggregated(
    String deviceId, {
    String interval = 'hour',
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        '/devices/$deviceId/readings/aggregated',
        queryParameters: {
          'interval': interval,
          if (from != null) 'from': from.toUtc().toIso8601String(),
          if (to != null) 'to': to.toUtc().toIso8601String(),
        },
      );
      return response.data!
          .map((e) => AggregatedBucket.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
