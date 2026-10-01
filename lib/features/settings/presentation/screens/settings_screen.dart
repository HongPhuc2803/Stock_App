import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider);
    final role = user?.role.toUpperCase() ?? 'STAFF';
    final storeId = user?.storeId ?? '';
    final storeAsync = ref.watch(storeStreamProvider(storeId));
    final basePath = role == 'OWNER'
        ? '/owner'
        : (role == 'WAREHOUSE_MANAGER' ? '/warehouse' : '/staff');

    final initials = user != null && user.name.isNotEmpty
        ? user.name.trim().split(' ').last[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Hồ Sơ & Cài Đặt',
          style: TextStyle(
            color: Color(0xFF004AC6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C30)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFD3E4FE),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004AC6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Chưa cập nhật',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 4),
                          storeAsync.when(
                            data: (store) => Text(
                              store?.name ?? 'SmartStock Store',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            loading: () => const SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                            ),
                            error: (e, s) =>
                                const Text('Error loading store name'),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role == 'OWNER'
                                  ? 'Admin Access'
                                  : (role == 'WAREHOUSE_MANAGER'
                                        ? 'Warehouse Manager'
                                        : 'Staff Access'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings List
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'CÀI ĐẶT CHUNG',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Profile settings
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        title: const Text('Hồ sơ cá nhân'),
                        subtitle: const Text('Thay đổi họ tên, số điện thoại'),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF94A3B8),
                        ),
                        onTap: () {
                          context.push('$basePath/settings/profile');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        title: const Text('Tùy chọn thông báo'),
                        subtitle: const Text(
                          'Cảnh báo tồn kho, đơn hàng và cập nhật kho',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.push('$basePath/settings/notifications'),
                      ),
                      if (role == 'OWNER') ...[
                        const Divider(height: 1),
                        // Store settings
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.store,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          title: const Text('Cấu hình cửa hàng'),
                          subtitle: const Text(
                            'Tên store, địa chỉ, số hóa đơn',
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF94A3B8),
                          ),
                          onTap: () {
                            context.push('$basePath/settings/store');
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.groups_outlined,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          title: const Text('Quản lý nhân viên'),
                          subtitle: const Text(
                            'Tạo tài khoản, phân quyền và khóa truy cập',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/owner/employees'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất tài khoản'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBA1A1A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Đăng xuất?'),
                      content: const Text(
                        'Giỏ hàng và dữ liệu chưa lưu trong phiên sẽ bị xóa.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Hủy'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Đăng xuất'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  await ref.read(authRepositoryProvider).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
