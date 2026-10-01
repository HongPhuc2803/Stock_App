import 'package:flutter_test/flutter_test.dart';
import 'package:smartstock/features/auth/data/models/user_model.dart';
import 'package:smartstock/features/settings/domain/entities/store.dart';

void main() {
  test('user model keeps profile and authorization fields', () {
    final user = UserModel.fromJson(const {
      'uid': 'user-1',
      'name': 'Nguyen An',
      'email': 'an@example.com',
      'role': 'STAFF',
      'storeId': 'store-1',
      'isActive': true,
      'phone': '0900000000',
      'avatarUrl': 'https://example.com/avatar.png',
    });

    expect(user.phone, '0900000000');
    expect(user.avatarUrl, isNotEmpty);
    expect(user.toJson()['role'], 'STAFF');
    expect(user.toJson()['storeId'], 'store-1');
  });

  test('store has safe operational defaults', () {
    const store = Store(
      id: 'store-1',
      name: 'SmartStock',
      ownerId: 'owner-1',
      address: '',
      phone: '',
    );

    expect(store.currency, 'USD');
    expect(store.timezone, 'Asia/Bangkok');
    expect(store.lowStockThreshold, 10);
  });
}
