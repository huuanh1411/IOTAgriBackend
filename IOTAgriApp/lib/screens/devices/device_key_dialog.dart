import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/device.dart';

/// Hop thoai hien thi DUY NHAT 1 LAN sau khi tao thiet bi thanh cong,
/// vi backend (DeviceEndpoints.CreateAsync) chi tra ve deviceKey dung 1
/// lan nay - cac lan GET/PUT sau khong con truong nay nua.
///
/// Kem theo topic MQTT chinh xac ma ESP32 phai publish toi, dung theo
/// dinh dang trong MqttIngestionService.cs: devices/{deviceKey}/readings
class DeviceKeyDialog extends StatelessWidget {
  const DeviceKeyDialog({super.key, required this.device});

  final NewDeviceResult device;

  static Future<void> show(BuildContext context, NewDeviceResult device) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeviceKeyDialog(device: device),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topic = 'devices/${device.deviceKey}/readings';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: const [
          Icon(Icons.vpn_key_outlined, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Da tao thiet bi'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('"${device.name}" da san sang. Hay luu lai Device Key ben duoi -'
                ' day la lan DUY NHAT ban co the xem no.'),
            const SizedBox(height: 16),
            _CopyableBox(label: 'Device Key', value: device.deviceKey),
            const SizedBox(height: 12),
            _CopyableBox(label: 'MQTT Topic can publish', value: topic),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amberSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Cau hinh ESP32 gui JSON toi topic tren, vi du:\n'
                '{ "temperature": 26.5, "humidity": 61.2, "ph": 6.1, '
                '"tds": 850, "waterLevel": 42.0 }',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Toi da luu lai'),
        ),
      ],
    );
  }
}

class _CopyableBox extends StatelessWidget {
  const _CopyableBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Da sao chep vao clipboard.')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
