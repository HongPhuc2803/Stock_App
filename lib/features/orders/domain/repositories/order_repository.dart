import '../entities/order.dart';

abstract class OrderRepository {
  Stream<List<AppOrder>> getOrders(String storeId);
  Future<String> createOrder(AppOrder order);
}
