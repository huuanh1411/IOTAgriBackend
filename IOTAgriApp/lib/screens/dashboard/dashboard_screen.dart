import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/sensor_metric.dart';
import '../../models/device_overview.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/nav_tab_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/metric_tile.dart';
import '../../widgets/online_badge.dart';

/// Man hinh tong quan - GET /api/dashboard/overview: liet ke moi thiet bi
/// cua nguoi dung kem reading moi nhat + trang thai online. Tu dong
/// polling moi 15s de cam giac gan real-time (backend chua co WebSocket).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.load();
      provider.startPolling();
    });
  }

  @override
  void dispose() {
    context.read<DashboardProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tong quan nong trai'),
        actions: [
          IconButton(
            tooltip: 'Lam moi',
            onPressed: () => context.read<DashboardProvider>().load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, DashboardProvider provider) {
    if (provider.loading && provider.overview.isEmpty) {
      return const LoadingView(message: 'Dang tai du lieu...');
    }
    if (provider.error != null && provider.overview.isEmpty) {
      return ErrorView(message: provider.error!, onRetry: () => provider.load());
    }
    if (provider.overview.isEmpty) {
      return EmptyState(
        icon: Icons.eco_outlined,
        title: 'Chua co thiet bi nao',
        message: 'Them thiet bi ESP32 dau tien de bat dau theo doi vuon cua ban.',
        actionLabel: 'Them thiet bi',
        onAction: () => context.read<NavTabProvider>().setIndex(1),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: provider.overview.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _LastUpdatedBar(lastUpdated: provider.lastUpdated);
          }
          final item = provider.overview[index - 1];
          return _OverviewCard(
            overview: item,
            onTap: () => context.push('/devices/${item.deviceId}'),
          );
        },
      ),
    );
  }
}

class _LastUpdatedBar extends StatelessWidget {
  const _LastUpdatedBar({required this.lastUpdated});

  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.sensors, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          lastUpdated == null
              ? 'Dang dong bo...'
              : 'Cap nhat luc ${AppFormatters.hourOnly.format(lastUpdated!)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.overview, required this.onTap});

  final DeviceOverview overview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reading = overview.latestReading;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(overview.name, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  OnlineBadge(isOnline: overview.isOnline),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                AppFormatters.timeAgo(overview.lastSeenAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              MetricGrid(
                valuesOf: (metric) => reading == null ? null : readingValueOf(metric, reading),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
