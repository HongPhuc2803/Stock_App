import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/settings_providers.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentAppUserProvider);
    if (user == null) return;
    final success = await ref
        .read(settingsControllerProvider.notifier)
        .updateUserProfile(
          user.uid,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã cập nhật hồ sơ.' : 'Không thể cập nhật hồ sơ.',
        ),
      ),
    );
  }

  Future<void> _sendPasswordReset() async {
    final user = ref.read(currentAppUserProvider);
    if (user == null) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(email: user.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã gửi hướng dẫn đổi mật khẩu tới ${user.email}.'
              : 'Không thể gửi email đổi mật khẩu.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAppUserProvider);
    if (!_initialized && user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _initialized = true;
    }
    final saving = ref.watch(settingsControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: user == null
          ? const Center(child: Text('Không tìm thấy tài khoản.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CircleAvatar(
                  radius: 42,
                  child: Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: user.email,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: user.role,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Vai trò',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Vui lòng nhập họ và tên'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Lưu hồ sơ'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _sendPasswordReset,
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('Gửi email đổi mật khẩu'),
                ),
              ],
            ),
    );
  }
}
