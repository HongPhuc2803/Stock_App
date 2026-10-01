import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final FirebaseFirestore _firestore;

  EmployeeRepositoryImpl(this._firestore);

  @override
  Stream<List<Employee>> getEmployees(String storeId) {
    return _firestore
        .collection('users')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
          // Exclude OWNER accounts from the employees list
          return snapshot.docs
              .map((doc) => EmployeeModel.fromFirestore(doc))
              .where((emp) => emp.role != 'OWNER')
              .toList();
        });
  }

  @override
  Future<void> createEmployee({
    required String name,
    required String email,
    required String password,
    required String role,
    required String storeId,
    required String createdBy,
  }) async {
    if (!{'STAFF', 'WAREHOUSE_MANAGER'}.contains(role)) {
      throw ArgumentError('Vai trò nhân viên không hợp lệ.');
    }
    FirebaseApp? tempApp;
    try {
      tempApp = await Firebase.initializeApp(
        name: 'employee-${DateTime.now().microsecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final cred = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      final model = EmployeeModel(
        uid: uid,
        name: name.trim(),
        email: email,
        role: role,
        storeId: storeId,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();
      batch.set(_firestore.collection('users').doc(uid), model.toFirestore());
      batch.set(_firestore.collection('audit_logs').doc(), {
        'storeId': storeId,
        'actorId': createdBy,
        'targetId': uid,
        'action': 'EMPLOYEE_CREATED',
        'changes': {'role': role, 'email': email},
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      await tempAuth.signOut();
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  @override
  Future<void> toggleEmployeeActiveStatus({
    required String uid,
    required bool isActive,
    required String storeId,
    required String changedBy,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final snapshot = await userRef.get();
    if (!snapshot.exists || snapshot.data()?['storeId'] != storeId) {
      throw StateError('Nhân viên không thuộc cửa hàng.');
    }
    if (snapshot.data()?['role'] == 'OWNER' || uid == changedBy) {
      throw StateError('Không thể khóa tài khoản Owner hiện tại.');
    }
    final batch = _firestore.batch();
    batch.update(userRef, {
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_firestore.collection('audit_logs').doc(), {
      'storeId': storeId,
      'actorId': changedBy,
      'targetId': uid,
      'action': isActive ? 'EMPLOYEE_ACTIVATED' : 'EMPLOYEE_DEACTIVATED',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<void> updateEmployee({
    required String uid,
    required String name,
    required String role,
    required String storeId,
    required String changedBy,
  }) async {
    if (!{'STAFF', 'WAREHOUSE_MANAGER'}.contains(role)) {
      throw ArgumentError('Vai trò nhân viên không hợp lệ.');
    }
    final userRef = _firestore.collection('users').doc(uid);
    final auditRef = _firestore.collection('audit_logs').doc();
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists || snapshot.data()?['storeId'] != storeId) {
        throw StateError('Nhân viên không thuộc cửa hàng.');
      }
      if (snapshot.data()?['role'] == 'OWNER') {
        throw StateError('Không thể thay đổi tài khoản Owner.');
      }
      transaction.update(userRef, {'name': name.trim(), 'role': role});
      transaction.set(auditRef, {
        'storeId': storeId,
        'actorId': changedBy,
        'targetId': uid,
        'action': 'EMPLOYEE_UPDATED',
        'changes': {'name': name.trim(), 'role': role},
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
