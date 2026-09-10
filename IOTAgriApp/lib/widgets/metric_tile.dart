import 'package:flutter/material.dart';
import '../core/utils/sensor_metric.dart';

/// The hien thi 1 chi so cam bien (dung trong luoi tren Dashboard va
/// man hinh chi tiet thiet bi). Anh xa icon/mau/don vi lay tu
/// core/utils/sensor_metric.dart de dam bao dong nhat trong toan app.
class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.metric, required this.value});

  final SensorMetric metric;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final info = kSensorMetricInfo[metric]!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: info.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, color: info.color, size: 22),
          const SizedBox(height: 8),
          Text(
            formatMetricValue(metric, value),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: info.color),
          ),
          const SizedBox(height: 2),
          Text(info.label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Luoi hien thi ca 5 chi so cung luc tu 1 SensorReading (co the null neu
/// thiet bi chua tung gui du lieu nao).
class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key, required this.valuesOf});

  /// Ham lay gia tri cho tung metric - cho phep tai su dung ca voi
  /// SensorReading va truong hop chi co gia tri don le.
  final double? Function(SensorMetric metric) valuesOf;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.05,
      children: SensorMetric.values
          .map((m) => MetricTile(metric: m, value: valuesOf(m)))
          .toList(),
    );
  }
}
