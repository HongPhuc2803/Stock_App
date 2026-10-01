import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../providers/product_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedCategoryId;

  // Variants list
  final List<ProductVariant> _variants = [];

  // Controllers for adding a new variant
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _costController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');

  bool _isLoadingProduct = false;
  Product? _existingProduct;
  XFile? _pickedImage;
  double? _uploadProgress;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProductDetails();
    }
  }

  Future<void> _loadProductDetails() async {
    setState(() {
      _isLoadingProduct = true;
    });

    try {
      final repo = ref.read(productRepositoryProvider);
      final product = await repo.getProductById(widget.productId!);
      if (product != null) {
        final variants = await repo.getProductVariants(widget.productId!);
        setState(() {
          _existingProduct = product;
          _nameController.text = product.name;
          _descController.text = product.description;
          _imageUrlController.text = product.imageUrl;
          _selectedCategoryId = product.categoryId;
          _variants.addAll(variants);
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoadingProduct = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _addVariant() {
    if (_skuController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền SKU và Giá bán của biến thể'),
        ),
      );
      return;
    }

    final sku = _skuController.text.trim();
    final barcode = _barcodeController.text.trim();
    final costPrice = double.tryParse(_costController.text);
    final sellingPrice = double.tryParse(_priceController.text);
    if (costPrice == null ||
        costPrice < 0 ||
        sellingPrice == null ||
        sellingPrice < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giá vốn và giá bán phải là số không âm.'),
        ),
      );
      return;
    }
    if (_variants.any((item) => item.sku.toUpperCase() == sku.toUpperCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SKU bị trùng trong danh sách biến thể.')),
      );
      return;
    }
    if (barcode.isNotEmpty &&
        _variants.any((item) => item.barcode == barcode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barcode bị trùng trong danh sách biến thể.'),
        ),
      );
      return;
    }

    final newVariant = ProductVariant(
      id: '',
      productId: widget.productId ?? '',
      sku: sku,
      barcode: barcode,
      color: _colorController.text.trim(),
      size: _sizeController.text.trim(),
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      stock: 0,
      storeId: ref.read(currentStoreIdProvider) ?? '',
    );

    setState(() {
      _variants.add(newVariant);
      // Clear inputs
      _skuController.clear();
      _barcodeController.clear();
      _colorController.clear();
      _sizeController.clear();
      _costController.clear();
      _priceController.clear();
      _stockController.text = '0';
    });
  }

  void _removeVariant(int index) {
    setState(() {
      _variants.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm phải có ít nhất 1 biến thể')),
      );
      return;
    }

    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    var imageUrl = _imageUrlController.text.trim();
    if (_pickedImage != null) {
      try {
        imageUrl = await ref
            .read(productImageServiceProvider)
            .upload(
              file: _pickedImage!,
              storeId: storeId,
              onProgress: (progress) {
                if (mounted) setState(() => _uploadProgress = progress);
              },
            );
      } catch (error) {
        if (mounted) {
          setState(() => _uploadProgress = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không thể tải ảnh lên: ${userErrorMessage(error)}',
              ),
            ),
          );
        }
        return;
      }
    }

    final productData = Product(
      id: widget.productId ?? '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      imageUrl: imageUrl,
      categoryId: _selectedCategoryId ?? '',
      storeId: storeId,
      createdAt: _existingProduct?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (widget.productId != null) {
      success = await ref
          .read(productFormControllerProvider.notifier)
          .updateProduct(product: productData, variants: _variants);
    } else {
      success = await ref
          .read(productFormControllerProvider.notifier)
          .createProduct(product: productData, variants: _variants);
    }

    if (mounted) {
      if (success) {
        final oldUrl = _existingProduct?.imageUrl ?? '';
        if (_pickedImage != null && oldUrl.isNotEmpty && oldUrl != imageUrl) {
          try {
            await ref.read(productImageServiceProvider).deleteByUrl(oldUrl);
          } catch (_) {
            // The product is already saved. A failed best-effort cleanup must
            // not turn a successful update into a user-visible failure.
          }
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lưu thông tin sản phẩm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(productFormControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error?.toString() ?? 'Lỗi khi lưu sản phẩm. Vui lòng thử lại.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickProductImage() async {
    try {
      final image = await ref.read(productImageServiceProvider).pickImage();
      if (image != null && mounted) setState(() => _pickedImage = image);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: ${userErrorMessage(error)}'),
          ),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    final catNameController = TextEditingController();
    final catDescController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Danh mục Mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: catNameController,
              decoration: const InputDecoration(labelText: 'Tên danh mục'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: catDescController,
              decoration: const InputDecoration(labelText: 'Mô tả ngắn'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Lưu'),
            onPressed: () async {
              final name = catNameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);

              final storeId = ref.read(currentStoreIdProvider) ?? '';
              final newCat = Category(
                id: FirebaseFirestore.instance
                    .collection('categories')
                    .doc()
                    .id,
                name: name,
                description: catDescController.text.trim(),
                storeId: storeId,
                createdAt: DateTime.now(),
              );

              await ref.read(productRepositoryProvider).createCategory(newCat);
              setState(() {
                _selectedCategoryId = newCat.id;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final formState = ref.watch(productFormControllerProvider);
    final isSaving = formState.isLoading;

    if (_isLoadingProduct) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          widget.productId != null ? 'Sửa Sản Phẩm' : 'Thêm Sản Phẩm Mới',
        ),
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
              // General Info Card
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
                        'Thông tin chung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Product Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên sản phẩm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên sản phẩm';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      Row(
                        children: [
                          Expanded(
                            child: categoriesAsync.when(
                              data: (categories) {
                                return DropdownButtonFormField<String>(
                                  initialValue: _selectedCategoryId,
                                  decoration: InputDecoration(
                                    labelText: 'Danh mục',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                  ),
                                  items: categories.map((cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedCategoryId = val;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng chọn danh mục';
                                    }
                                    return null;
                                  },
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (e, s) => Text(
                                'Lỗi tải danh mục: ${userErrorMessage(e)}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.1),
                              foregroundColor: const Color(0xFF2563EB),
                            ),
                            onPressed: _showAddCategoryDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Mô tả sản phẩm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      OutlinedButton.icon(
                        onPressed: isSaving ? null : _pickProductImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(
                          _pickedImage == null
                              ? 'Chọn ảnh từ thiết bị'
                              : 'Đã chọn: ${_pickedImage!.name}',
                        ),
                      ),
                      if (_uploadProgress != null) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: _uploadProgress),
                        const SizedBox(height: 4),
                        Text(
                          'Đang tải ảnh: ${(_uploadProgress! * 100).round()}%',
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Image URL
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'URL Ảnh sản phẩm (tùy chọn)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Variants Card
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
                        'Danh sách biến thể',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Existing variants list
                      if (_variants.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              'Chưa có biến thể nào. Vui lòng thêm biến thể bên dưới.',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                      ...List.generate(_variants.length, (index) {
                        final v = _variants[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${v.sku} (Size: ${v.size}, Color: ${v.color})',
                          ),
                          subtitle: Text(
                            'Giá: \$${v.sellingPrice} - Vốn: \$${v.costPrice} - Tồn: ${v.stock}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeVariant(index),
                          ),
                        );
                      }),
                      const Divider(height: 32),

                      // Add Variant sub-form
                      const Text(
                        'Thêm biến thể mới',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF434655),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _skuController,
                              decoration: const InputDecoration(
                                labelText: 'SKU *',
                                hintText: 'HD-BLK-L',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _barcodeController,
                              decoration: const InputDecoration(
                                labelText: 'Barcode',
                                hintText: '8934567',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _colorController,
                              decoration: const InputDecoration(
                                labelText: 'Màu sắc',
                                hintText: 'Black',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _sizeController,
                              decoration: const InputDecoration(
                                labelText: 'Kích cỡ',
                                hintText: 'L',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _costController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Giá vốn',
                                hintText: '20.0',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Giá bán *',
                                hintText: '45.0',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _stockController,
                              enabled: false,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Tồn kho',
                                hintText: '50',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF2563EB,
                          ).withValues(alpha: 0.1),
                          foregroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Xác nhận thêm biến thể'),
                        onPressed: _addVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
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
                        'Lưu sản phẩm',
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
