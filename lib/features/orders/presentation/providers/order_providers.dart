import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(firestoreProvider));
});

final ordersStreamProvider = StreamProvider<List<AppOrder>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const Stream.empty();
  return ref.watch(orderRepositoryProvider).getOrders(storeId);
});

class OrderFormController extends StateNotifier<AsyncValue<String?>> {
  final OrderRepository _repository;

  OrderFormController(this._repository) : super(const AsyncValue.data(null));

  Future<String?> createOrder(AppOrder order) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _repository.createOrder(order));
    state = result;
    return result.value;
  }
}

final orderFormControllerProvider =
    StateNotifierProvider<OrderFormController, AsyncValue<String?>>((ref) {
      return OrderFormController(ref.watch(orderRepositoryProvider));
    });
