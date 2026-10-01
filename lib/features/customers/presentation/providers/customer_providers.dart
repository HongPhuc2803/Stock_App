import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(firestoreProvider));
});

final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const Stream.empty();
  return ref.watch(customerRepositoryProvider).getCustomers(storeId);
});

final selectedCartCustomerProvider = StateProvider<Customer?>((ref) => null);

class CustomerFormController extends StateNotifier<AsyncValue<void>> {
  final CustomerRepository _repository;

  CustomerFormController(this._repository) : super(const AsyncValue.data(null));

  Future<bool> createCustomer(Customer customer) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.createCustomer(customer);
    });
    state = result;
    return !result.hasError;
  }

  Future<bool> updateCustomer(Customer customer) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.updateCustomer(customer);
    });
    state = result;
    return !result.hasError;
  }

  Future<bool> archiveCustomer(String customerId, String storeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.archiveCustomer(customerId, storeId),
    );
    return !state.hasError;
  }
}

final customerFormControllerProvider =
    StateNotifierProvider<CustomerFormController, AsyncValue<void>>((ref) {
      return CustomerFormController(ref.watch(customerRepositoryProvider));
    });
