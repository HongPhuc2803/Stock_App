import '../entities/customer.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> getCustomers(String storeId);
  Future<void> createCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> archiveCustomer(String customerId, String storeId);
}
