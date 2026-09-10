import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../models/device_overview.dart';
import '../services/dashboard_service.dart';

/// Quan ly du lieu man hinh Dashboard, tuong ung GET /api/dashboard/overview.
/// Ho tro polling dinh ky de mo phong cam giac "gan real-time" (backend
/// nhan du lieu qua MQTT lien tuc tu ESP32, nen client can tu lam moi
/// dinh ky vi khong co WebSocket/SignalR o backend hien tai).
class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._service);

  final DashboardService _service;

  List<DeviceOverview> _overview = [];
  List<DeviceOverview> get overview => _overview;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;

  Timer? _pollingTimer;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _overview = await _service.getOverview();
      _error = null;
      _lastUpdated = DateTime.now();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Bat dau tu lam moi moi [interval] (mac dinh 15s) - goi trong initState
  /// cua DashboardScreen, va nho goi [stopPolling] trong dispose.
  void startPolling({Duration interval = const Duration(seconds: 15)}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) => load(silent: true));
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
