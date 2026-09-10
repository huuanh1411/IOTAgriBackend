import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/utils/formatters.dart';
import '../core/utils/sensor_metric.dart';
import '../models/aggregated_bucket.dart';

/// Ve bieu do duong the hien gia tri TRUNG BINH cua 1 chi so cam bien theo
/// tung bucket thoi gian - du lieu lay tu
/// GET /api/devices/{id}/readings/aggregated (tinh san trong PostgreSQL).
class AggregatedChart extends StatelessWidget {
  const AggregatedChart({
    super.key,
    required this.buckets,
    required this.metric,
    required this.interval,
  });

  final List<AggregatedBucket> buckets;
  final SensorMetric metric;
  final String interval;

  @override
  Widget build(BuildContext context) {
    final info = kSensorMetricInfo[metric]!;

    final points = <FlSpot>[];
    for (var i = 0; i < buckets.length; i++) {
      final avg = bucketAvgOf(metric, buckets[i]);
      if (avg != null) {
        points.add(FlSpot(i.toDouble(), avg));
      }
    }

    if (points.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'Chua co du lieu ${info.label.toLowerCase()} trong khoang thoi gian nay.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    var minY = points.first.y;
    var maxY = points.first.y;
    for (final p in points) {
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }
    final span = (maxY - minY).abs();
    final padding = span < 1 ? 1.0 : span * 0.2;

    final xStep = (buckets.length / 4).ceil();
    final safeXInterval = xStep < 1 ? 1.0 : xStep.toDouble();

    return SizedBox(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8),
        child: LineChart(
          LineChartData(
            minY: minY - padding,
            maxY: maxY + padding,
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    value.toStringAsFixed(info.decimals == 0 ? 0 : 1),
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: safeXInterval,
                  getTitlesWidget: (value, meta) {
                    final idx = value.round();
                    if (idx < 0 || idx >= buckets.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        AppFormatters.bucketLabel(interval, buckets[idx].bucketStart),
                        style: const TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                  final idx = s.x.round();
                  final label = (idx >= 0 && idx < buckets.length)
                      ? AppFormatters.bucketLabel(interval, buckets[idx].bucketStart)
                      : '';
                  return LineTooltipItem(
                    '$label\n${formatMetricValue(metric, s.y)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: points,
                isCurved: true,
                color: info.color,
                barWidth: 2.6,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      info.color.withValues(alpha: 0.28),
                      info.color.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
