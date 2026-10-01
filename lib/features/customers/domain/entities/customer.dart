class Customer {
  final String id;
  final String storeId;
  final String name;
  final String phone;
  final String email;
  final String company;
  final String address;
  final double totalSpent;
  final int ordersCount;
  final int loyaltyPoints;
  final bool isVip;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.storeId,
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.address,
    required this.totalSpent,
    required this.ordersCount,
    required this.loyaltyPoints,
    required this.isVip,
    required this.createdAt,
  });

  double get avgOrderValue => ordersCount > 0 ? totalSpent / ordersCount : 0.0;
}
