import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Home (POS)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final success = await ref
                  .read(authControllerProvider.notifier)
                  .logout();
              if (success && context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Chào mừng Nhân viên bán hàng (Staff)! Giao diện POS bán hàng.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
