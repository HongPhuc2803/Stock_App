class Employee {
  final String uid;
  final String name;
  final String email;
  final String role; // STAFF, WAREHOUSE_MANAGER
  final String storeId;
  final bool isActive;
  final DateTime createdAt;

  const Employee({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.storeId,
    required this.isActive,
    required this.createdAt,
  });
}
