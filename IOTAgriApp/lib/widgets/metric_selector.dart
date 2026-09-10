import 'package:flutter/material.dart';
import '../core/utils/sensor_metric.dart';

/// Hang chip cho phep chon 1 trong 5 chi so cam bien de xem tren bieu do.
class MetricSelector extends StatelessWidget {
  const MetricSelector({super.key, required this.value, required this.onChanged});

  final SensorMetric value;
  final void Function(SensorMetric) onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SensorMetric.values.map((metric) {
          final info = kSensorMetricInfo[metric]!;
          final selected = metric == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(
                info.icon,
                size: 16,
                color: selected ? Colors.white : info.color,
              ),
              label: Text(info.label),
              selected: selected,
              selectedColor: info.color,
              onSelected: (_) => onChanged(metric),
              labelStyle: TextStyle(color: selected ? Colors.white : null),
            ),
          );
        }).toList(),
      ),
    );
  }
}
