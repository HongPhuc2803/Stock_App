import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/inventory_providers.dart';

class AdjustStockScreen extends ConsumerStatefulWidget {
  const AdjustStockScreen({super.key});

  @override
  ConsumerState<AdjustStockScreen> createState() => _AdjustStockScreenState();
}

class _AdjustStockScreenState extends ConsumerState<AdjustStockScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVariantId;
  int _currentStock = 0;
  final _targetQtyController = TextEditingController();
  final _noteController = TextEditingController();
  String _adjustmentType = 'ADJUSTMENT'; // ADJUSTMENT or DAMAGE

  @override
  void dispose() {
    _targetQtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onVariantSelected(String? variantId, List<VariantWithProduct> list) {
    if (variantId == null) return;
    final item = list.firstWhere((element) => element.variant.id == variantId);
    setState(() {
      _selectedVariantId = variantId;
      _currentStock = item.variant.stock;
      _targetQtyController.text = '$_currentStock';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVariantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn biến sản phẩm cần điều chỉnh'),
        ),
      );
      return;
    }

    final targetQty = int.tryParse(_targetQtyController.text) ?? 0;
    final netDifference = targetQty - _currentStock;

    if (netDifference == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Số lượng điều chỉnh mới trùng khớp với tồn hiện tại. Không cần điều chỉnh.',
          ),
        ),
      );
      return;
    }

    final storeId = ref.read(currentStoreIdProvider);
    final user = ref.read(currentAppUserProvider);
    if (storeId == null || user == null) return;

    final success = await ref
        .read(inventoryFormControllerProvider.notifier)
        .executeStockTransaction(
          variantId: _selectedVariantId!,
          quantity: netDifference,
          type: _adjustmentType,
          createdBy: user.uid,
          storeId: storeId,
          reason: _adjustmentType,
          note: _noteController.text.trim(),
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Điều chỉnh số lượng tồn kho thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(inventoryFormControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error?.toString() ?? 'Lỗi khi điều chỉnh kho. Vui lòng thử lại.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantsWithProductsAsync = ref.watch(variantsWithProductsProvider);
    final formState = ref.watch(inventoryFormControllerProvider);
    final isSaving = formState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Điều Chỉnh Kho (Adjustment)'),
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
              // Section 1: Selection
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
                        '1. Chọn sản phẩm / Biến thể',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                      const SizedBox(height: 16),

                      variantsWithProductsAsync.when(
                        data: (list) {
                          return DropdownButtonFormField<String>(
                            initialValue: _selectedVariantId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Sản phẩm & Biến thể',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: list.map((item) {
                              final variant = item.variant;
                              final name =
                                  item.product?.name ?? 'Unknown Product';
                              final details =
                                  '(${variant.sku} - Size: ${variant.size}, Color: ${variant.color})';

                              return DropdownMenuItem<String>(
                                value: variant.id,
                                child: Text(
                                  '$name $details',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => _onVariantSelected(val, list),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Vui lòng chọn biến thể';
                              }
                              return null;
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, s) =>
                            Text('Lỗi tải sản phẩm: ${userErrorMessage(e)}'),
                      ),

                      if (_selectedVariantId != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Số lượng tồn hiện tại:',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                            Text(
                              '$_currentStock',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Section 2: Details
              if (_selectedVariantId != null)
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
                          '2. Thông tin điều chỉnh',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Adjustment type selection
                        DropdownButtonFormField<String>(
                          initialValue: _adjustmentType,
                          decoration: InputDecoration(
                            labelText: 'Lý do điều chỉnh',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'ADJUSTMENT',
                              child: Text('Kiểm kê kho (ADJUSTMENT)'),
                            ),
                            DropdownMenuItem(
                              value: 'DAMAGE',
                              child: Text('Hàng hỏng / Lỗi (DAMAGE)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _adjustmentType = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _noteController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Ghi chú điều chỉnh',
                          ),
                          validator: (value) {
                            final target =
                                int.tryParse(_targetQtyController.text) ??
                                _currentStock;
                            if (target < _currentStock &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Cần nhập ghi chú khi giảm tồn kho';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Target Quantity Form
                        TextFormField(
                          controller: _targetQtyController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Số lượng tồn thực tế mới',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (val) {
                            // Trigger rebuild to update net difference calculation in UI
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập số lượng mới';
                            }
                            final qty = int.tryParse(value);
                            if (qty == null || qty < 0) {
                              return 'Số lượng phải là số nguyên không âm';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Net difference calculation preview
                        Builder(
                          builder: (context) {
                            final target =
                                int.tryParse(_targetQtyController.text) ??
                                _currentStock;
                            final diff = target - _currentStock;
                            final isDecrease = diff < 0;

                            if (diff == 0) return const SizedBox();

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  isDecrease
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  size: 16,
                                  color: isDecrease ? Colors.red : Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Chênh lệch thuần: ${diff > 0 ? "+" : ""}$diff',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDecrease
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isSaving || _selectedVariantId == null
                    ? null
                    : _submit,
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
                        'Xác nhận điều chỉnh',
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
