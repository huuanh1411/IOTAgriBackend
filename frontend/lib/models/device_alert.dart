class DeviceAlert {
  final String id;
  final String deviceId;
  final String type;
  final double measuredValue;
  final double threshold;
  final String triggeredAt;
  final String? resolvedAt;

  DeviceAlert({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.measuredValue,
    required this.threshold,
    required this.triggeredAt,
    this.resolvedAt,
  });

  factory DeviceAlert.fromJson(Map<String, dynamic> json) {
    return DeviceAlert(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      type: json['type'] ?? '',
      measuredValue: (json['measuredValue'] ?? 0).toDouble(),
      threshold: (json['threshold'] ?? 0).toDouble(),
      triggeredAt: json['triggeredAt'] ?? '',
      resolvedAt: json['resolvedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'type': type,
      'measuredValue': measuredValue,
      'threshold': threshold,
      'triggeredAt': triggeredAt,
      'resolvedAt': resolvedAt,
    };
  }
}