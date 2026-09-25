class SensorReading {
  final String id;
  final String deviceId;
  final double? temperature;
  final double? humidity;
  final double? ph;
  final double? tds;
  final double? waterLevel;
  final String recordedAt;

  SensorReading({
    required this.id,
    required this.deviceId,
    this.temperature,
    this.humidity,
    this.ph,
    this.tds,
    this.waterLevel,
    required this.recordedAt,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      ph: json['ph']?.toDouble(),
      tds: json['tds']?.toDouble(),
      waterLevel: json['waterLevel']?.toDouble(),
      recordedAt: json['recordedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'temperature': temperature,
      'humidity': humidity,
      'ph': ph,
      'tds': tds,
      'waterLevel': waterLevel,
      'recordedAt': recordedAt,
    };
  }
}