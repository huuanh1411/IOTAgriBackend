import 'package:flutter/material.dart';
import '../../models/aggregated_bucket.dart';
import '../../models/sensor_reading.dart';
import '../theme/app_colors.dart';

/// Noi TAP TRUNG DUY NHAT anh xa 5 chi so cam bien ma backend ho tro
/// (Temperature, Humidity, Ph, Tds, WaterLevel - dung theo dung ten
/// field trong Models/SensorReading.cs). Moi widget hien thi so lieu
/// (the chi so, bieu do, danh sach lich su) deu dung chung dinh nghia
/// nay de dam bao nhat quan va de bao tri khi backend thay doi.
enum SensorMetric { temperature, humidity, ph, tds, waterLevel }

class SensorMetricInfo {
  const SensorMetricInfo({
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
    required this.surfaceColor,
    required this.decimals,
  });

  final String label;
  final String unit;
  final IconData icon;
  final Color color;
  final Color surfaceColor;
  final int decimals;
}

const Map<SensorMetric, SensorMetricInfo> kSensorMetricInfo = {
  SensorMetric.temperature: SensorMetricInfo(
    label: 'Nhiet do',
    unit: '\u00b0C',
    icon: Icons.thermostat_outlined,
    color: AppColors.amber,
    surfaceColor: AppColors.amberSurface,
    decimals: 1,
  ),
  SensorMetric.humidity: SensorMetricInfo(
    label: 'Do am',
    unit: '%',
    icon: Icons.water_drop_outlined,
    color: AppColors.water,
    surfaceColor: AppColors.waterSurface,
    decimals: 0,
  ),
  SensorMetric.ph: SensorMetricInfo(
    label: 'Do pH',
    unit: '',
    icon: Icons.science_outlined,
    color: AppColors.violet,
    surfaceColor: AppColors.violetSurface,
    decimals: 2,
  ),
  SensorMetric.tds: SensorMetricInfo(
    label: 'TDS',
    unit: 'ppm',
    icon: Icons.bubble_chart_outlined,
    color: AppColors.orange,
    surfaceColor: AppColors.orangeSurface,
    decimals: 0,
  ),
  SensorMetric.waterLevel: SensorMetricInfo(
    label: 'Muc nuoc',
    unit: '%',
    icon: Icons.waves_outlined,
    color: AppColors.primary,
    surfaceColor: AppColors.primarySurface,
    decimals: 0,
  ),
};

/// Lay gia tri hien tai (tu 1 SensorReading) theo tung metric.
double? readingValueOf(SensorMetric metric, SensorReading reading) {
  switch (metric) {
    case SensorMetric.temperature:
      return reading.temperature;
    case SensorMetric.humidity:
      return reading.humidity;
    case SensorMetric.ph:
      return reading.ph;
    case SensorMetric.tds:
      return reading.tds;
    case SensorMetric.waterLevel:
      return reading.waterLevel;
  }
}

/// Lay gia tri trung binh/min/max (tu 1 AggregatedBucket) theo tung metric.
double? bucketAvgOf(SensorMetric metric, AggregatedBucket b) {
  switch (metric) {
    case SensorMetric.temperature:
      return b.avgTemperature;
    case SensorMetric.humidity:
      return b.avgHumidity;
    case SensorMetric.ph:
      return b.avgPh;
    case SensorMetric.tds:
      return b.avgTds;
    case SensorMetric.waterLevel:
      return b.avgWaterLevel;
  }
}

double? bucketMinOf(SensorMetric metric, AggregatedBucket b) {
  switch (metric) {
    case SensorMetric.temperature:
      return b.minTemperature;
    case SensorMetric.humidity:
      return b.minHumidity;
    case SensorMetric.ph:
      return b.minPh;
    case SensorMetric.tds:
      return b.minTds;
    case SensorMetric.waterLevel:
      return b.minWaterLevel;
  }
}

double? bucketMaxOf(SensorMetric metric, AggregatedBucket b) {
  switch (metric) {
    case SensorMetric.temperature:
      return b.maxTemperature;
    case SensorMetric.humidity:
      return b.maxHumidity;
    case SensorMetric.ph:
      return b.maxPh;
    case SensorMetric.tds:
      return b.maxTds;
    case SensorMetric.waterLevel:
      return b.maxWaterLevel;
  }
}

String formatMetricValue(SensorMetric metric, double? value) {
  if (value == null) return '--';
  final info = kSensorMetricInfo[metric]!;
  final numberText = value.toStringAsFixed(info.decimals);
  return info.unit.isEmpty ? numberText : '$numberText${info.unit}';
}
