import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../providers/product_providers.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final nameController = TextEditingController(text: category?.name);
    final descriptionController = TextEditingController(
      text: category?.description,
    );
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(category == null ? 'Thêm danh mục' : 'Sửa danh mục'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Tên danh mục'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập tên danh mục'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (result != true || !context.mounted) return;

    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;
    final value = Category(
      id: category?.id ?? '',
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      storeId: storeId,
      createdAt: category?.createdAt ?? DateTime.now(),
    );
    try {
      final repository = ref.read(productRepositoryProvider);
      if (category == null) {
        await repository.createCategory(value);
      } else {
        await repository.updateCategory(value);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lưu danh mục: ${userErrorMessage(error)}'),
          ),
        );
      }
    } finally {
      nameController.dispose();
      descriptionController.dispose();
    }
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lưu trữ danh mục?'),
        content: Text(
          'Danh mục “${category.name}” chỉ có thể lưu trữ khi không còn sản phẩm đang sử dụng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Lưu trữ'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(productRepositoryProvider)
          .archiveCategory(category.id, category.storeId);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý danh mục')),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(categoriesStreamProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử tải lại'),
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Chưa có danh mục nào.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final category = items[index];
                  return ListTile(
                    title: Text(category.name),
                    subtitle: category.description.isEmpty
                        ? null
                        : Text(category.description),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editCategory(context, ref, category: category);
                        } else {
                          _archive(context, ref, category);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                        PopupMenuItem(value: 'archive', child: Text('Lưu trữ')),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editCategory(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Thêm danh mục'),
      ),
    );
  }
}
