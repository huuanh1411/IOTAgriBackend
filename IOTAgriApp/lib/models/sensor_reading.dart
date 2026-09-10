/// Tuong ung Dtos/Sensors/SensorReadingResponse.cs
class SensorReading {
  const SensorReading({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.tds,
    required this.waterLevel,
    required this.recordedAt,
  });

  final String id;
  final double? temperature;
  final double? humidity;
  final double? ph;
  final double? tds;
  final double? waterLevel;
  final DateTime recordedAt;

  factory SensorReading.fromJson(Map<String, dynamic> json) => SensorReading(
        id: json['id'] as String,
        temperature: (json['temperature'] as num?)?.toDouble(),
        humidity: (json['humidity'] as num?)?.toDouble(),
        ph: (json['ph'] as num?)?.toDouble(),
        tds: (json['tds'] as num?)?.toDouble(),
        waterLevel: (json['waterLevel'] as num?)?.toDouble(),
        recordedAt: DateTime.parse(json['recordedAt'] as String).toLocal(),
      );
}
