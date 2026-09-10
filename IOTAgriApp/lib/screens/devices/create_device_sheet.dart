import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// Bottom sheet nhap ten thiet bi moi - tuong ung CreateDeviceRequest
/// { "name": string } cua POST /api/devices.
class CreateDeviceSheet extends StatefulWidget {
  const CreateDeviceSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateDeviceSheet(),
    );
  }

  @override
  State<CreateDeviceSheet> createState() => _CreateDeviceSheetState();
}

class _CreateDeviceSheetState extends State<CreateDeviceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    Navigator.of(context).pop(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text('Them thiet bi moi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Dat ten de de nhan biet, vi du: "Vuon rau tang 2".',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _nameController,
              label: 'Ten thiet bi',
              icon: Icons.developer_board_outlined,
              textInputAction: TextInputAction.done,
              validator: Validators.deviceName,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Tao thiet bi', onPressed: _submit, loading: _submitting),
          ],
        ),
      ),
    );
  }
}
