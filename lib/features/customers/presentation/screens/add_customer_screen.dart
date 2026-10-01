import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_providers.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const AddCustomerScreen({super.key, this.customerId});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isVip = false;
  Customer? _existingCustomer;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _initFields(List<Customer> list) {
    if (_initialized) return;
    final matching = list.where((c) => c.id == widget.customerId).toList();
    _existingCustomer = matching.isNotEmpty ? matching.first : null;
    if (_existingCustomer != null) {
      _nameController.text = _existingCustomer!.name;
      _phoneController.text = _existingCustomer!.phone;
      _emailController.text = _existingCustomer!.email;
      _companyController.text = _existingCustomer!.company;
      _addressController.text = _existingCustomer!.address;
      _isVip = _existingCustomer!.isVip;
    }
    _initialized = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không tìm thấy storeId.')));
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final customerObj = Customer(
      id: _existingCustomer?.id ?? '',
      storeId: storeId,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      company: _companyController.text.trim(),
      address: _addressController.text.trim(),
      totalSpent: _existingCustomer?.totalSpent ?? 0.0,
      ordersCount: _existingCustomer?.ordersCount ?? 0,
      loyaltyPoints: _existingCustomer?.loyaltyPoints ?? 0,
      isVip: _isVip,
      createdAt: _existingCustomer?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (_existingCustomer != null) {
      success = await ref
          .read(customerFormControllerProvider.notifier)
          .updateCustomer(customerObj);
    } else {
      success = await ref
          .read(customerFormControllerProvider.notifier)
          .createCustomer(customerObj);
    }

    if (mounted) {
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _existingCustomer != null
                  ? 'Đã cập nhật thông tin khách hàng!'
                  : 'Đã thêm khách hàng mới thành công!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      } else {
        final error = ref.read(customerFormControllerProvider).error;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              error?.toString() ?? 'Lỗi khi lưu thông tin khách hàng.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(customerFormControllerProvider);
    final isSaving = formState.isLoading;

    if (widget.customerId != null) {
      ref.watch(customersStreamProvider).whenData((list) {
        _initFields(list);
      });
    }

    final titleText = _existingCustomer != null
        ? 'Sửa Khách Hàng'
        : 'Thêm Khách Hàng Mới';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(titleText),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C30)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
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
                        'Thông tin cá nhân',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên khách hàng',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên khách hàng';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email liên hệ (tùy chọn)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                        'Thông tin bổ sung',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Company
                      TextFormField(
                        controller: _companyController,
                        decoration: InputDecoration(
                          labelText: 'Công ty / Đơn vị (tùy chọn)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.business_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Địa chỉ giao hàng (tùy chọn)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Đánh dấu khách hàng VIP',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Hội viên VIP sẽ có nhãn riêng trong danh mục và giỏ hàng.',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _isVip,
                  activeTrackColor: const Color(0xFF2563EB),
                  onChanged: null,
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
                        'Lưu thông tin khách hàng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
