import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

class WarehouseHomeScreen extends ConsumerWidget {
  const WarehouseHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Manager Home'),
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
          'Chào mừng Thủ kho (Warehouse Manager)! Giao diện quản lý kho hàng.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
