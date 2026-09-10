import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/device.dart';
import '../../providers/device_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/device_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import 'create_device_sheet.dart';
import 'device_key_dialog.dart';

/// Man hinh quan ly thiet bi - anh xa day du CRUD cua DeviceEndpoints.cs.
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().loadDevices();
    });
  }

  Future<void> _handleCreate() async {
    final name = await CreateDeviceSheet.show(context);
    if (name == null || !mounted) return;
    try {
      final created = await context.read<DeviceProvider>().createDevice(name);
      if (!mounted) return;
      await DeviceKeyDialog.show(context, created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Khong the tao thiet bi: $e')),
      );
    }
  }

  Future<void> _handleRename(Device device) async {
    final controller = TextEditingController(text: device.name);
    final formKey = GlobalKey<FormState>();
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Doi ten thiet bi'),
        content: Form(
          key: formKey,
          child: AppTextField(
            controller: controller,
            label: 'Ten thiet bi',
            icon: Icons.edit_outlined,
            validator: Validators.deviceName,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huy')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Luu'),
          ),
        ],
      ),
    );

    if (newName == null || !mounted) return;
    final success = await context.read<DeviceProvider>().renameDevice(device.id, newName);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<DeviceProvider>().error ?? 'Doi ten that bai.')),
      );
    }
  }

  Future<void> _handleDelete(Device device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa thiet bi?'),
        content: Text(
          '"${device.name}" va TOAN BO lich su du lieu cam bien lien quan se bi xoa vinh vien.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final success = await context.read<DeviceProvider>().deleteDevice(device.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da xoa thiet bi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<DeviceProvider>().error ?? 'Xoa that bai.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Thiet bi cua toi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleCreate,
        icon: const Icon(Icons.add),
        label: const Text('Them thiet bi'),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(DeviceProvider provider) {
    if (provider.loading && provider.devices.isEmpty) {
      return const LoadingView(message: 'Dang tai danh sach thiet bi...');
    }
    if (provider.error != null && provider.devices.isEmpty) {
      return ErrorView(message: provider.error!, onRetry: () => provider.loadDevices());
    }
    if (provider.devices.isEmpty) {
      return EmptyState(
        icon: Icons.developer_board_outlined,
        title: 'Chua co thiet bi nao',
        message: 'Nhan "Them thiet bi" de tao ma bi mat (Device Key) cho ESP32 dau tien.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadDevices(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        itemCount: provider.devices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final device = provider.devices[index];
          return DeviceCard(
            name: device.name,
            isOnline: device.isOnline,
            lastSeenAt: device.lastSeenAt,
            onTap: () => context.push('/devices/${device.id}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'rename') _handleRename(device);
                if (value == 'delete') _handleDelete(device);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'rename', child: Text('Doi ten')),
                PopupMenuItem(value: 'delete', child: Text('Xoa')),
              ],
            ),
          );
        },
      ),
    );
  }
}
