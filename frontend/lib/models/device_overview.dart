import 'sensor_reading.dart';
import 'device_alert.dart';

class DeviceOverview {
  final String id;
  final String name;
  final bool isOnline;
  final String? lastSeenAt;
  final SensorReading? latestReading;
  final List<DeviceAlert> alerts;

  DeviceOverview({
    required this.id,
    required this.name,
    required this.isOnline,
    this.lastSeenAt,
    this.latestReading,
    required this.alerts,
  });

  factory DeviceOverview.fromJson(Map<String, dynamic> json) {
    return DeviceOverview(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeenAt: json['lastSeenAt'],
      latestReading: json['latestReading'] != null 
          ? SensorReading.fromJson(json['latestReading']) 
          : null,
      alerts: (json['alerts'] as List<dynamic>?)
          ?.map((alert) => DeviceAlert.fromJson(alert))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt,
      'latestReading': latestReading?.toJson(),
      'alerts': alerts.map((alert) => alert.toJson()).toList(),
    };
  }
}