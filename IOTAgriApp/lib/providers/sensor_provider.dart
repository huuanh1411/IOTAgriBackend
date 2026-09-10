import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../models/aggregated_bucket.dart';
import '../models/sensor_reading.dart';
import '../services/sensor_service.dart';

/// Quan ly du lieu man hinh chi tiet thiet bi: lich su reading tho +
/// du lieu tong hop theo khoang thoi gian, tuong ung Endpoints/SensorEndpoints.cs.
class SensorProvider extends ChangeNotifier {
  SensorProvider(this._service);

  final SensorService _service;

  static const List<String> allowedIntervals = ['minute', 'hour', 'day', 'week', 'month'];

  String _interval = 'hour';
  String get interval => _interval;

  List<SensorReading> _readings = [];
  List<SensorReading> get readings => _readings;

  List<AggregatedBucket> _buckets = [];
  List<AggregatedBucket> get buckets => _buckets;

  bool _loadingReadings = false;
  bool get loadingReadings => _loadingReadings;

  bool _loadingAggregated = false;
  bool get loadingAggregated => _loadingAggregated;

  String? _error;
  String? get error => _error;

  Future<void> loadAll(String deviceId) async {
    await Future.wait([
      loadReadings(deviceId),
      loadAggregated(deviceId),
    ]);
  }

  Future<void> loadReadings(String deviceId, {int take = 30}) async {
    _loadingReadings = true;
    notifyListeners();
    try {
      _readings = await _service.getReadings(deviceId, take: take);
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loadingReadings = false;
      notifyListeners();
    }
  }

  Future<void> loadAggregated(String deviceId, {DateTime? from, DateTime? to}) async {
    _loadingAggregated = true;
    notifyListeners();
    try {
      _buckets = await _service.getAggregated(
        deviceId,
        interval: _interval,
        from: from ?? _defaultFromFor(_interval),
        to: to,
      );
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loadingAggregated = false;
      notifyListeners();
    }
  }

  Future<void> changeInterval(String deviceId, String newInterval) async {
    if (newInterval == _interval) return;
    _interval = newInterval;
    notifyListeners();
    await loadAggregated(deviceId);
  }

  /// Chon khoang nhin mac dinh hop ly cho tung interval de bieu do khong
  /// bi qua thua hoac qua thieu diem du lieu.
  DateTime _defaultFromFor(String interval) {
    final now = DateTime.now();
    switch (interval) {
      case 'minute':
        return now.subtract(const Duration(hours: 2));
      case 'hour':
        return now.subtract(const Duration(days: 2));
      case 'day':
        return now.subtract(const Duration(days: 30));
      case 'week':
        return now.subtract(const Duration(days: 90));
      case 'month':
        return now.subtract(const Duration(days: 365));
      default:
        return now.subtract(const Duration(days: 7));
    }
  }

  void reset() {
    _readings = [];
    _buckets = [];
    _interval = 'hour';
    _error = null;
  }
}
