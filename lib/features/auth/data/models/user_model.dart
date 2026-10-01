import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,

    required super.name,

    required super.email,

    required super.role,

    required super.storeId,

    required super.isActive,
    super.phone,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',

      name: json['name'] ?? '',

      email: json['email'] ?? '',

      role: json['role'] ?? '',

      storeId: json['storeId'] ?? '',

      isActive: json['isActive'] ?? true,
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,

      "name": name,

      "email": email,

      "role": role,

      "storeId": storeId,

      "isActive": isActive,
      "phone": phone,
      "avatarUrl": avatarUrl,
    };
  }
}
