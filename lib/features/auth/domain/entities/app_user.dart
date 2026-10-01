class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String storeId;
  final bool isActive;
  final String phone;
  final String avatarUrl;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.storeId,
    required this.isActive,
    this.phone = '',
    this.avatarUrl = '',
  });
}
