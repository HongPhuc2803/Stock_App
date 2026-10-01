import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../domain/entities/store.dart';
import '../providers/settings_providers.dart';

class StoreSettingsScreen extends ConsumerStatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  ConsumerState<StoreSettingsScreen> createState() =>
      _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends ConsumerState<StoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _thresholdController = TextEditingController();
  String _currency = 'USD';
  String _timezone = 'Asia/Bangkok';
  bool _initialized = false;
  Store? _storeObj;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _initFields(Store? store) {
    if (_initialized || store == null) return;
    _storeObj = store;
    _nameController.text = store.name;
    _phoneController.text = store.phone;
    _addressController.text = store.address;
    _thresholdController.text = '${store.lowStockThreshold}';
    _currency = store.currency;
    _timezone = store.timezone;
    _initialized = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _storeObj == null) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final updatedStore = Store(
      id: _storeObj!.id,
      name: _nameController.text.trim(),
      ownerId: _storeObj!.ownerId,
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      currency: _currency,
      timezone: _timezone,
      lowStockThreshold: int.parse(_thresholdController.text),
    );

    final success = await ref
        .read(settingsControllerProvider.notifier)
        .updateStore(updatedStore);

    if (mounted) {
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin cửa hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      } else {
        final error = ref.read(settingsControllerProvider).error;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              error?.toString() ?? 'Lỗi khi cập nhật cấu hình cửa hàng.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAppUserProvider);
    final storeId = user?.storeId ?? '';
    final storeAsync = ref.watch(storeStreamProvider(storeId));

    storeAsync.whenData((store) {
      _initFields(store);
    });

    final formState = ref.watch(settingsControllerProvider);
    final isSaving = formState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Cấu Hình Cửa Hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C30)),
          onPressed: () => context.pop(),
        ),
      ),
      body: storeAsync.when(
        data: (store) {
          if (store == null) {
            return const Center(child: Text('Không tìm thấy thông tin store.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin Store',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Store Name
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Tên cửa hàng / Store Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.storefront_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tên cửa hàng';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Store Phone
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại liên hệ cửa hàng',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Store Address
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Địa chỉ cửa hàng',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _currency,
                            decoration: const InputDecoration(
                              labelText: 'Đơn vị tiền tệ',
                              prefixIcon: Icon(Icons.payments_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'USD',
                                child: Text('USD'),
                              ),
                              DropdownMenuItem(
                                value: 'VND',
                                child: Text('VND'),
                              ),
                              DropdownMenuItem(
                                value: 'THB',
                                child: Text('THB'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _currency = value ?? _currency),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _timezone,
                            decoration: const InputDecoration(
                              labelText: 'Múi giờ',
                              prefixIcon: Icon(Icons.schedule_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Asia/Bangkok',
                                child: Text('Asia/Bangkok (UTC+7)'),
                              ),
                              DropdownMenuItem(
                                value: 'Asia/Ho_Chi_Minh',
                                child: Text('Asia/Ho Chi Minh (UTC+7)'),
                              ),
                              DropdownMenuItem(
                                value: 'UTC',
                                child: Text('UTC'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _timezone = value ?? _timezone),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _thresholdController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Ngưỡng cảnh báo tồn kho thấp',
                              prefixIcon: Icon(Icons.warning_amber_outlined),
                            ),
                            validator: (value) {
                              final number = int.tryParse(value ?? '');
                              if (number == null || number < 0) {
                                return 'Ngưỡng tồn kho phải là số không âm';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Lưu cấu hình cửa hàng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Text('Lỗi tải thông tin store: ${userErrorMessage(e)}'),
        ),
      ),
    );
  }
}
