import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/sensor_metric.dart';
import '../../models/sensor_reading.dart';
import '../../providers/device_provider.dart';
import '../../providers/sensor_provider.dart';
import '../../widgets/aggregated_chart.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/interval_selector.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/metric_selector.dart';
import '../../widgets/online_badge.dart';
import '../../widgets/section_title.dart';

/// Man hinh chi tiet 1 thiet bi:
///  - GET /api/devices/{id}/readings              -> lich su gan nhat
///  - GET /api/devices/{id}/readings/aggregated    -> bieu do theo khoang
/// Ca hai deu duoc backend kiem tra ownership (OwnerId == user hien tai)
/// truoc khi tra du lieu.
class DeviceDetailScreen extends StatefulWidget {
  const DeviceDetailScreen({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  SensorMetric _selectedMetric = SensorMetric.temperature;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SensorProvider>();
      provider.reset();
      provider.loadAll(widget.deviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final device = context.watch<DeviceProvider>().findById(widget.deviceId);
    final sensor = context.watch<SensorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(device?.name ?? 'Chi tiet thiet bi'),
        actions: [
          IconButton(
            tooltip: 'Lam moi',
            icon: const Icon(Icons.refresh),
            onPressed: () => sensor.loadAll(widget.deviceId),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => sensor.loadAll(widget.deviceId),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            if (device != null) _StatusHeader(isOnline: device.isOnline, lastSeenAt: device.lastSeenAt),
            const SizedBox(height: 8),
            const SectionTitle('Bieu do theo thoi gian'),
            MetricSelector(
              value: _selectedMetric,
              onChanged: (m) => setState(() => _selectedMetric = m),
            ),
            const SizedBox(height: 12),
            IntervalSelector(
              value: sensor.interval,
              onChanged: (interval) => context.read<SensorProvider>().changeInterval(widget.deviceId, interval),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: sensor.loadingAggregated
                    ? const LoadingView(message: 'Dang tinh toan du lieu tong hop...')
                    : sensor.error != null && sensor.buckets.isEmpty
                        ? ErrorView(
                            message: sensor.error!,
                            onRetry: () => sensor.loadAggregated(widget.deviceId),
                          )
                        : AggregatedChart(
                            buckets: sensor.buckets,
                            metric: _selectedMetric,
                            interval: sensor.interval,
                          ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Lich su gan day'),
            _ReadingsList(sensor: sensor, deviceId: widget.deviceId),
          ],
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.isOnline, required this.lastSeenAt});

  final bool isOnline;
  final DateTime? lastSeenAt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.primarySurface : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.sensors,
                color: isOnline ? AppColors.primary : AppColors.offline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnlineBadge(isOnline: isOnline),
                  const SizedBox(height: 4),
                  Text(
                    'Lan cuoi nhan du lieu: ${AppFormatters.timeAgo(lastSeenAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingsList extends StatelessWidget {
  const _ReadingsList({required this.sensor, required this.deviceId});

  final SensorProvider sensor;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    if (sensor.loadingReadings && sensor.readings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: LoadingView(),
      );
    }
    if (sensor.readings.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'Chua co du lieu',
        message: 'Thiet bi chua gui reading nao qua MQTT.',
      );
    }

    return Column(
      children: sensor.readings.map((r) => _ReadingTile(reading: r)).toList(),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  const _ReadingTile({required this.reading});

  final SensorReading reading;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppFormatters.dateTime.format(reading.recordedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: SensorMetric.values.map((metric) {
                final info = kSensorMetricInfo[metric]!;
                final value = readingValueOf(metric, reading);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(info.icon, size: 14, color: info.color),
                    const SizedBox(width: 4),
                    Text(formatMetricValue(metric, value), style: const TextStyle(fontSize: 12.5)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
