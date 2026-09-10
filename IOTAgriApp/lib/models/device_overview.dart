import 'sensor_reading.dart';

/// Tuong ung Dtos/Dashboard/DeviceOverviewResponse.cs
class DeviceOverview {
  const DeviceOverview({
    required this.deviceId,
    required this.name,
    required this.isOnline,
    required this.lastSeenAt,
    required this.latestReading,
  });

  final String deviceId;
  final String name;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final SensorReading? latestReading;

  factory DeviceOverview.fromJson(Map<String, dynamic> json) => DeviceOverview(
        deviceId: json['deviceId'] as String,
        name: json['name'] as String,
        isOnline: json['isOnline'] as bool,
        lastSeenAt: json['lastSeenAt'] == null
            ? null
            : DateTime.parse(json['lastSeenAt'] as String).toLocal(),
        latestReading: json['latestReading'] == null
            ? null
            : SensorReading.fromJson(json['latestReading'] as Map<String, dynamic>),
      );
}
