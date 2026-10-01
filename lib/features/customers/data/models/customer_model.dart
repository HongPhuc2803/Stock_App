import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.storeId,
    required super.name,
    required super.phone,
    required super.email,
    required super.company,
    required super.address,
    required super.totalSpent,
    required super.ordersCount,
    required super.loyaltyPoints,
    required super.isVip,
    required super.createdAt,
  });

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CustomerModel(
      id: doc.id,
      storeId: data['storeId'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      company: data['company'] ?? '',
      address: data['address'] ?? '',
      totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
      ordersCount: (data['ordersCount'] as num?)?.toInt() ?? 0,
      loyaltyPoints: (data['loyaltyPoints'] as num?)?.toInt() ?? 0,
      isVip: data['isVip'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'storeId': storeId,
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
      'address': address,
      'totalSpent': totalSpent,
      'ordersCount': ordersCount,
      'loyaltyPoints': loyaltyPoints,
      'isVip': isVip,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
