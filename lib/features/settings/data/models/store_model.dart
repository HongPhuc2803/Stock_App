import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/store.dart';

class StoreModel extends Store {
  const StoreModel({
    required super.id,
    required super.name,
    required super.ownerId,
    required super.address,
    required super.phone,
    super.currency,
    super.timezone,
    super.lowStockThreshold,
  });

  factory StoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StoreModel(
      id: doc.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      currency: data['currency'] ?? 'USD',
      timezone: data['timezone'] ?? 'Asia/Bangkok',
      lowStockThreshold: (data['lowStockThreshold'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerId': ownerId,
      'address': address,
      'phone': phone,
      'currency': currency,
      'timezone': timezone,
      'lowStockThreshold': lowStockThreshold,
    };
  }
}
