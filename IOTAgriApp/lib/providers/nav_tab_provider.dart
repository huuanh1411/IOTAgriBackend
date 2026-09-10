import 'package:flutter/foundation.dart';

/// Dieu phoi tab dang chon trong AppShell (Dashboard / Devices / Ca nhan).
/// Cho phep cac man hinh con (vi du nut "Them thiet bi" tren Dashboard)
/// chuyen tab ma khong can dinh nghia them route long nhau trong GoRouter.
class NavTabProvider extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void setIndex(int value) {
    if (_index == value) return;
    _index = value;
    notifyListeners();
  }
}
