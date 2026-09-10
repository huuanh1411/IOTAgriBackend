import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final DateFormat dateTime = DateFormat('HH:mm dd/MM/yyyy');
  static final DateFormat dateOnly = DateFormat('dd/MM/yyyy');
  static final DateFormat hourOnly = DateFormat('HH:mm');
  static final DateFormat dayMonth = DateFormat('dd/MM');
  static final DateFormat monthYear = DateFormat('MM/yyyy');

  /// Hien thi "x phut truoc" / "x gio truoc" ... tuong tu cach nhieu app
  /// IoT hien thi lastSeenAt cho de hinh dung.
  static String timeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Chua co du lieu';
    final diff = DateTime.now().difference(dateTime);
    if (diff.isNegative || diff.inSeconds < 10) return 'Vua xong';
    if (diff.inMinutes < 1) return '${diff.inSeconds} giay truoc';
    if (diff.inHours < 1) return '${diff.inMinutes} phut truoc';
    if (diff.inDays < 1) return '${diff.inHours} gio truoc';
    if (diff.inDays < 30) return '${diff.inDays} ngay truoc';
    return AppFormatters.dateOnly.format(dateTime);
  }

  /// Chon dinh dang truc X cho bieu do tuy theo khoang thoi gian dang xem,
  /// khop voi cac gia tri interval ma SensorEndpoints.cs cho phep
  /// (minute, hour, day, week, month).
  static String bucketLabel(String interval, DateTime bucketStart) {
    switch (interval) {
      case 'minute':
      case 'hour':
        return hourOnly.format(bucketStart);
      case 'day':
      case 'week':
        return dayMonth.format(bucketStart);
      case 'month':
        return monthYear.format(bucketStart);
      default:
        return dayMonth.format(bucketStart);
    }
  }
}
