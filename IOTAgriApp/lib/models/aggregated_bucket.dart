/// Tuong ung Dtos/Dashboard/AggregatedReadingBucket.cs
/// (ket qua tinh min/avg/max theo tung khoang thoi gian, tinh trong PostgreSQL)
class AggregatedBucket {
  const AggregatedBucket({
    required this.bucketStart,
    required this.avgTemperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.avgHumidity,
    required this.minHumidity,
    required this.maxHumidity,
    required this.avgPh,
    required this.minPh,
    required this.maxPh,
    required this.avgTds,
    required this.minTds,
    required this.maxTds,
    required this.avgWaterLevel,
    required this.minWaterLevel,
    required this.maxWaterLevel,
    required this.sampleCount,
  });

  final DateTime bucketStart;
  final double? avgTemperature;
  final double? minTemperature;
  final double? maxTemperature;
  final double? avgHumidity;
  final double? minHumidity;
  final double? maxHumidity;
  final double? avgPh;
  final double? minPh;
  final double? maxPh;
  final double? avgTds;
  final double? minTds;
  final double? maxTds;
  final double? avgWaterLevel;
  final double? minWaterLevel;
  final double? maxWaterLevel;
  final int sampleCount;

  static double? _d(dynamic v) => (v as num?)?.toDouble();

  factory AggregatedBucket.fromJson(Map<String, dynamic> json) => AggregatedBucket(
        bucketStart: DateTime.parse(json['bucketStart'] as String).toLocal(),
        avgTemperature: _d(json['avgTemperature']),
        minTemperature: _d(json['minTemperature']),
        maxTemperature: _d(json['maxTemperature']),
        avgHumidity: _d(json['avgHumidity']),
        minHumidity: _d(json['minHumidity']),
        maxHumidity: _d(json['maxHumidity']),
        avgPh: _d(json['avgPh']),
        minPh: _d(json['minPh']),
        maxPh: _d(json['maxPh']),
        avgTds: _d(json['avgTds']),
        minTds: _d(json['minTds']),
        maxTds: _d(json['maxTds']),
        avgWaterLevel: _d(json['avgWaterLevel']),
        minWaterLevel: _d(json['minWaterLevel']),
        maxWaterLevel: _d(json['maxWaterLevel']),
        sampleCount: json['sampleCount'] as int,
      );
}
