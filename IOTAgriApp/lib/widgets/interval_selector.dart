import 'package:flutter/material.dart';

class IntervalOption {
  const IntervalOption(this.value, this.label);
  final String value;
  final String label;
}

const List<IntervalOption> kIntervalOptions = [
  IntervalOption('minute', 'Phut'),
  IntervalOption('hour', 'Gio'),
  IntervalOption('day', 'Ngay'),
  IntervalOption('week', 'Tuan'),
  IntervalOption('month', 'Thang'),
];

/// Bo chon khoang thoi gian tong hop - khop chinh xac voi
/// SensorEndpoints.AllowedIntervals ben backend (minute/hour/day/week/month).
class IntervalSelector extends StatelessWidget {
  const IntervalSelector({super.key, required this.value, required this.onChanged});

  final String value;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kIntervalOptions.map((option) {
          final selected = option.value == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option.label),
              selected: selected,
              onSelected: (_) => onChanged(option.value),
              labelStyle: TextStyle(color: selected ? Colors.white : null),
            ),
          );
        }).toList(),
      ),
    );
  }
}
