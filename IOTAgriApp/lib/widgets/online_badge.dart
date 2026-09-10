import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Hien thi trang thai online/offline cua thiet bi (Device.IsOnline).
///
/// Luu y logic: gia tri nay lay truc tiep tu field IsOnline luu trong DB,
/// hien tai backend CHI set true khi nhan duoc message MQTT, chua co co
/// che tu dong set lai false khi thiet bi ngung gui du lieu qua lau. Vi
/// vay UI hien them "lastSeenAt" ben canh de nguoi dung tu doi chieu, thay
/// vi chi tin tuyet doi vao nhan online/offline.
class OnlineBadge extends StatelessWidget {
  const OnlineBadge({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.online : AppColors.offline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Dang hoat dong' : 'Ngoai tuyen',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
