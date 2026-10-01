import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/presentation/providers/product_providers.dart';
import '../providers/settings_providers.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Không có tài khoản.')));
    }
    final preferences = ref.watch(notificationPreferencesProvider(user.uid));
    return Scaffold(
      appBar: AppBar(title: const Text('Tùy chọn thông báo')),
      body: preferences.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Không thể tải tùy chọn thông báo.')),
        data: (values) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PreferenceTile(
              title: 'Cảnh báo tồn kho thấp',
              subtitle: 'Nhận cảnh báo khi sản phẩm sắp hoặc đã hết hàng.',
              value: values['lowStock'] ?? true,
              onChanged: (value) =>
                  _save(ref, user.uid, {...values, 'lowStock': value}),
            ),
            _PreferenceTile(
              title: 'Đơn hàng mới',
              subtitle: 'Nhận thông báo khi một đơn được thanh toán.',
              value: values['newOrder'] ?? true,
              onChanged: (value) =>
                  _save(ref, user.uid, {...values, 'newOrder': value}),
            ),
            _PreferenceTile(
              title: 'Cập nhật kho',
              subtitle: 'Nhận thông báo về nhập và điều chỉnh kho.',
              value: values['stockUpdated'] ?? true,
              onChanged: (value) =>
                  _save(ref, user.uid, {...values, 'stockUpdated': value}),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(WidgetRef ref, String uid, Map<String, bool> values) {
    return ref
        .read(settingsControllerProvider.notifier)
        .updateNotificationPreferences(uid, values);
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
