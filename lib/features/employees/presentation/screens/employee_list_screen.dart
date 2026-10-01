import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/employee_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../domain/entities/employee.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  Future<void> _editEmployee(
    BuildContext context,
    WidgetRef ref,
    Employee employee,
  ) async {
    final nameController = TextEditingController(text: employee.name);
    var role = employee.role;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Chỉnh sửa nhân viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Vai trò'),
                items: const [
                  DropdownMenuItem(
                    value: 'STAFF',
                    child: Text('Nhân viên bán hàng'),
                  ),
                  DropdownMenuItem(
                    value: 'WAREHOUSE_MANAGER',
                    child: Text('Quản lý kho'),
                  ),
                ],
                onChanged: (value) =>
                    setDialogState(() => role = value ?? role),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || nameController.text.trim().isEmpty) {
      nameController.dispose();
      return;
    }
    final actor = ref.read(currentAppUserProvider);
    if (actor == null) return;
    final success = await ref
        .read(employeeFormControllerProvider.notifier)
        .updateEmployee(
          uid: employee.uid,
          name: nameController.text.trim(),
          role: role,
          storeId: actor.storeId,
          changedBy: actor.uid,
        );
    nameController.dispose();
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(employeeFormControllerProvider).error.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesStreamProvider);
    final formState = ref.watch(employeeFormControllerProvider);
    final isSaving = formState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Quản Lý Nhân Viên',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh Sách Nhân Viên',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Thêm mới và cấp quyền hoạt động cho nhân viên.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF434655),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm nhân viên'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isSaving
                      ? null
                      : () {
                          context.push('/owner/employees/create');
                        },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Employee List
            employeesAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: Text(
                        'Cửa hàng chưa có nhân viên nào. Hãy thêm nhân viên mới!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final employee = list[index];
                    final roleLabel = employee.role == 'WAREHOUSE_MANAGER'
                        ? 'Thủ Kho (Warehouse Manager)'
                        : 'Nhân Viên Bán Hàng (Staff)';

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // User Info Icon
                            CircleAvatar(
                              backgroundColor: employee.isActive
                                  ? const Color(0xFFD3E4FE)
                                  : const Color(0xFFF1F5F9),
                              child: Icon(
                                Icons.person_outline,
                                color: employee.isActive
                                    ? const Color(0xFF004AC6)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Employee Email & Role
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.name.isEmpty
                                        ? employee.email
                                        : employee.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0B1C30),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (employee.name.isNotEmpty)
                                    Text(
                                      employee.email,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  Text(
                                    roleLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Switch to Toggle active status
                            Column(
                              children: [
                                IconButton(
                                  tooltip: 'Chỉnh sửa',
                                  onPressed: isSaving
                                      ? null
                                      : () => _editEmployee(
                                          context,
                                          ref,
                                          employee,
                                        ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                Switch(
                                  value: employee.isActive,
                                  activeTrackColor: const Color(0xFF2563EB),
                                  onChanged: isSaving
                                      ? null
                                      : (val) async {
                                          final actor = ref.read(
                                            currentAppUserProvider,
                                          );
                                          if (actor == null) return;
                                          final success = await ref
                                              .read(
                                                employeeFormControllerProvider
                                                    .notifier,
                                              )
                                              .toggleActiveStatus(
                                                uid: employee.uid,
                                                isActive: val,
                                                storeId: actor.storeId,
                                                changedBy: actor.uid,
                                              );
                                          if (!success && context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  ref
                                                      .read(
                                                        employeeFormControllerProvider,
                                                      )
                                                      .error
                                                      .toString(),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                ),
                                Text(
                                  employee.isActive ? 'Hoạt động' : 'Đã khóa',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: employee.isActive
                                        ? const Color(0xFF00714d)
                                        : const Color(0xFFba1a1a),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(
                child: Text(
                  'Lỗi tải danh sách nhân viên: ${userErrorMessage(e)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
