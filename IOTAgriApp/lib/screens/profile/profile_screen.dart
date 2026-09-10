import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';

/// Man hinh Ca nhan: hien thi thong tin nguoi dung (giai ma tu claim trong
/// JWT access token - backend hien khong co endpoint GET /me rieng) va
/// nut Dang xuat (goi POST /api/auth/logout de thu hoi refresh token
/// hien tai truoc khi xoa session cuc bo).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dang xuat?'),
        content: const Text('Ban se can dang nhap lai de tiep tuc su dung ung dung.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Dang xuat'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ca nhan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 42, color: AppColors.primary),
                ),
                const SizedBox(height: 14),
                Text(
                  auth.fullName ?? 'Nguoi dung AgriSense',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  auth.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _InfoTile(icon: Icons.dns_outlined, label: 'May chu API', value: ApiConfig.baseUrl),
          const Divider(height: 32),
          AppButton(
            label: 'Dang xuat',
            icon: Icons.logout,
            variant: AppButtonVariant.danger,
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'AgriSense v1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
