class Store {
  final String id;
  final String name;
  final String ownerId;
  final String address;
  final String phone;
  final String currency;
  final String timezone;
  final int lowStockThreshold;

  const Store({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.address,
    required this.phone,
    this.currency = 'USD',
    this.timezone = 'Asia/Bangkok',
    this.lowStockThreshold = 10,
  });
}
