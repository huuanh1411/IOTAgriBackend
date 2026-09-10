import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../models/device.dart';
import '../services/device_service.dart';

/// Quan ly danh sach thiet bi cua nguoi dung hien tai (CRUD), tuong ung
/// truc tiep voi Endpoints/DeviceEndpoints.cs.
class DeviceProvider extends ChangeNotifier {
  DeviceProvider(this._service);

  final DeviceService _service;

  List<Device> _devices = [];
  List<Device> get devices => _devices;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> loadDevices({bool silent = false}) async {
    if (!silent) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _devices = await _service.list();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Tra ve NewDeviceResult (co chua deviceKey) de UI hien thi 1 lan duy nhat.
  Future<NewDeviceResult> createDevice(String name) async {
    final result = await _service.create(name);
    await loadDevices(silent: true);
    return result;
  }

  Future<bool> renameDevice(String id, String newName) async {
    try {
      final updated = await _service.rename(id, newName);
      final index = _devices.indexWhere((d) => d.id == id);
      if (index != -1) {
        _devices[index] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDevice(String id) async {
    try {
      await _service.delete(id);
      _devices.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Device? findById(String id) {
    for (final d in _devices) {
      if (d.id == id) return d;
    }
    return null;
  }
}
