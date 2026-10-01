import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Firestore indexes file is valid and covers production queries', () {
    final json =
        jsonDecode(File('firestore.indexes.json').readAsStringSync())
            as Map<String, dynamic>;
    final indexes = json['indexes'] as List<dynamic>;
    final collections = indexes
        .cast<Map<String, dynamic>>()
        .map((index) => index['collectionGroup'])
        .toSet();

    expect(
      collections,
      containsAll(<String>{
        'categories',
        'products',
        'orders',
        'inventory_transactions',
        'notifications',
      }),
    );
  });

  test('Firestore and Storage rules use deny-by-default fallbacks', () {
    final firestoreRules = File('firestore.rules').readAsStringSync();
    final storageRules = File('storage.rules').readAsStringSync();

    expect(firestoreRules, contains('match /{document=**}'));
    expect(storageRules, contains('match /{allPaths=**}'));
    expect(storageRules, contains('profile().isActive == true'));
    expect(storageRules, contains("image/(jpeg|png|webp)"));
  });

  test('release build never falls back to the debug signing key', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
    expect(gradle, contains('isMinifyEnabled = true'));
    expect(gradle, contains('isShrinkResources = true'));
  });
}
