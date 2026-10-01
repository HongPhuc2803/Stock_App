import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import '../../../../core/services/app_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_item.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../providers/cart_providers.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/providers/customer_providers.dart';

class PosCartDialog extends ConsumerStatefulWidget {
  const PosCartDialog({super.key});

  @override
  ConsumerState<PosCartDialog> createState() => _PosCartDialogState();
}

class _PosCartDialogState extends ConsumerState<PosCartDialog> {
  final _discountController = TextEditingController();
  final _cashReceivedController = TextEditingController();
  String _paymentMethod = 'CASH';
  String? _checkoutRequestId;

  @override
  void initState() {
    super.initState();
    final discount = ref.read(cartProvider).discount;
    if (discount > 0) {
      _discountController.text = '$discount';
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _cashReceivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final orderState = ref.watch(orderFormControllerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chi Tiết Giỏ Hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // Items List
            Expanded(
              child: cart.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Giỏ hàng của bạn đang trống.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        final variant = item.variant;
                        final product = item.product;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              // Avatar / Mini Image
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: product.imageUrl.isNotEmpty
                                    ? Image.network(
                                        product.imageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.image_outlined,
                                        size: 20,
                                      ),
                              ),
                              const SizedBox(width: 8),

                              // Text details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${variant.sku} | Size: ${variant.size}, Color: ${variant.color}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      '\$${variant.sellingPrice.toStringAsFixed(2)} x ${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Add / Subtract / Delete controls
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: () {
                                      ref
                                          .read(cartProvider.notifier)
                                          .updateQuantity(
                                            variant.id,
                                            item.quantity - 1,
                                          );
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () {
                                      ref
                                          .read(cartProvider.notifier)
                                          .updateQuantity(
                                            variant.id,
                                            item.quantity + 1,
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),

            // Summary Info
            if (cart.items.isNotEmpty) ...[
              _buildCustomerSelector(ref),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tạm tính:',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  Text(
                    '\$${cart.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Discount input
              Row(
                children: [
                  const Text(
                    'Chiết khấu (\$):',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _discountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (val) {
                          final disc = double.tryParse(val) ?? 0.0;
                          ref.read(cartProvider.notifier).setDiscount(disc);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng thanh toán:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Phương thức thanh toán',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'CASH', child: Text('Tiền mặt')),
                  DropdownMenuItem(value: 'CARD', child: Text('Thẻ')),
                  DropdownMenuItem(value: 'ONLINE', child: Text('Online')),
                ],
                onChanged: orderState.isLoading
                    ? null
                    : (value) =>
                          setState(() => _paymentMethod = value ?? 'CASH'),
              ),
              if (_paymentMethod == 'CASH') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _cashReceivedController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Tiền khách đưa',
                    helperText: _cashReceivedController.text.isEmpty
                        ? null
                        : 'Tiền thừa: ${((double.tryParse(_cashReceivedController.text) ?? 0) - cart.total).clamp(0, double.infinity).toStringAsFixed(2)}',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 16),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: orderState.isLoading
                      ? null
                      : () async {
                          final storeId = ref.read(currentStoreIdProvider);
                          final user = ref.read(currentAppUserProvider);
                          if (storeId == null || user == null) return;
                          if (_paymentMethod == 'CASH') {
                            final cash = double.tryParse(
                              _cashReceivedController.text,
                            );
                            if (cash == null || cash < cart.total) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tiền khách đưa chưa đủ để thanh toán.',
                                  ),
                                ),
                              );
                              return;
                            }
                          }

                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          final orderItems = cart.items.map((item) {
                            return OrderItem(
                              variantId: item.variant.id,
                              productId: item.product.id,
                              productName: item.product.name,
                              sku: item.variant.sku,
                              color: item.variant.color,
                              size: item.variant.size,
                              price: item.variant.sellingPrice,
                              costPrice: item.variant.costPrice,
                              quantity: item.quantity,
                            );
                          }).toList();

                          final selectedCustomer = ref.read(
                            selectedCartCustomerProvider,
                          );

                          _checkoutRequestId ??=
                              '${user.uid}_${DateTime.now().microsecondsSinceEpoch}';
                          final newOrder = AppOrder(
                            id: _checkoutRequestId!,
                            storeId: storeId,
                            items: orderItems,
                            subtotal: cart.subtotal,
                            discount: cart.discount,
                            total: cart.total,
                            paymentStatus: 'PAID',
                            paymentMethod: _paymentMethod,
                            createdBy: user.uid,
                            createdAt: DateTime.now(),
                            customerId: selectedCustomer?.id,
                            customerName: selectedCustomer?.name,
                          );

                          final createdOrderId = await ref
                              .read(orderFormControllerProvider.notifier)
                              .createOrder(newOrder);

                          if (mounted) {
                            if (createdOrderId != null) {
                              await AppServices.logEvent('checkout_completed', {
                                'payment_method': _paymentMethod,
                                'item_count': orderItems.length,
                              });
                              ref.read(cartProvider.notifier).clearCart();
                              ref
                                      .read(
                                        selectedCartCustomerProvider.notifier,
                                      )
                                      .state =
                                  null;
                              navigator.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Thanh toán đơn hàng thành công và cập nhật tồn kho!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              final error = ref
                                  .read(orderFormControllerProvider)
                                  .error;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error == null
                                        ? 'Lỗi thanh toán. Vui lòng kiểm tra tồn kho.'
                                        : userErrorMessage(error),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: const Text('Thanh Toán (Checkout)'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSelector(WidgetRef ref) {
    final selectedCustomer = ref.watch(selectedCartCustomerProvider);

    if (selectedCustomer != null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: selectedCustomer.isVip
              ? const Color(0xFFFFF0D4)
              : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: selectedCustomer.isVip
                      ? const Color(0xFFB25E00)
                      : const Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Text(
                  selectedCustomer.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedCustomer.isVip
                        ? const Color(0xFFB25E00)
                        : const Color(0xFF1E40AF),
                  ),
                ),
                if (selectedCustomer.isVip) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB25E00).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'VIP',
                      style: TextStyle(
                        fontSize: 8,
                        color: Color(0xFFB25E00),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                ref.read(selectedCartCustomerProvider.notifier).state = null;
              },
            ),
          ],
        ),
      );
    }

    return TextButton.icon(
      icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
      label: const Text('Chọn Khách Hàng (Tích điểm)'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _CustomerSearchDialog(
            onSelected: (customer) {
              ref.read(selectedCartCustomerProvider.notifier).state = customer;
            },
          ),
        );
      },
    );
  }
}

class _CustomerSearchDialog extends ConsumerStatefulWidget {
  final ValueChanged<Customer> onSelected;

  const _CustomerSearchDialog({required this.onSelected});

  @override
  ConsumerState<_CustomerSearchDialog> createState() =>
      _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends ConsumerState<_CustomerSearchDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    return AlertDialog(
      title: const Text('Chọn Khách Hàng'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm tên, số điện thoại...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() {
                  _query = val.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: customersAsync.when(
                data: (list) {
                  final filtered = list
                      .where(
                        (c) =>
                            c.name.toLowerCase().contains(_query) ||
                            c.phone.contains(_query),
                      )
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy khách hàng.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final customer = filtered[index];
                      return ListTile(
                        title: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(customer.phone),
                        trailing: customer.isVip
                            ? const Icon(Icons.star, color: Colors.orange)
                            : null,
                        onTap: () {
                          widget.onSelected(customer);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Lỗi: ${userErrorMessage(e)}'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
