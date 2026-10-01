import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final FirebaseFirestore _firestore;

  CustomerRepositoryImpl(this._firestore);

  @override
  Stream<List<Customer>> getCustomers(String storeId) {
    return _firestore
        .collection('customers')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) => doc.data()['isActive'] != false)
              .map((doc) => CustomerModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> createCustomer(Customer customer) async {
    await _validateUniqueContact(customer);
    final docRef = _firestore.collection('customers').doc();
    final model = CustomerModel(
      id: docRef.id,
      storeId: customer.storeId,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      company: customer.company,
      address: customer.address,
      totalSpent: customer.totalSpent,
      ordersCount: customer.ordersCount,
      loyaltyPoints: customer.loyaltyPoints,
      isVip: customer.isVip,
      createdAt: customer.createdAt,
    );
    await docRef.set({...model.toFirestore(), 'isActive': true});
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _validateUniqueContact(customer, excludingId: customer.id);
    await _firestore.collection('customers').doc(customer.id).update({
      'name': customer.name.trim(),
      'phone': customer.phone.trim(),
      'email': customer.email.trim().toLowerCase(),
      'company': customer.company.trim(),
      'address': customer.address.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _validateUniqueContact(
    Customer customer, {
    String? excludingId,
  }) async {
    final snapshot = await _firestore
        .collection('customers')
        .where('storeId', isEqualTo: customer.storeId)
        .get();
    final phone = customer.phone.trim();
    final email = customer.email.trim().toLowerCase();
    final duplicated = snapshot.docs.any((doc) {
      final data = doc.data();
      if (doc.id == excludingId || data['isActive'] == false) return false;
      return (phone.isNotEmpty && data['phone'] == phone) ||
          (email.isNotEmpty &&
              (data['email'] as String? ?? '').toLowerCase() == email);
    });
    if (duplicated) {
      throw StateError('Số điện thoại hoặc email đã thuộc khách hàng khác.');
    }
  }

  @override
  Future<void> archiveCustomer(String customerId, String storeId) async {
    final reference = _firestore.collection('customers').doc(customerId);
    final snapshot = await reference.get();
    if (!snapshot.exists || snapshot.data()?['storeId'] != storeId) {
      throw StateError('Khách hàng không thuộc cửa hàng.');
    }
    await reference.update({
      'isActive': false,
      'archivedAt': FieldValue.serverTimestamp(),
    });
  }
}
