import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepositoryImpl(ref.watch(firestoreProvider));
});

final employeesStreamProvider = StreamProvider<List<Employee>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const Stream.empty();
  return ref.watch(employeeRepositoryProvider).getEmployees(storeId);
});

class EmployeeFormController extends StateNotifier<AsyncValue<void>> {
  final EmployeeRepository _repository;

  EmployeeFormController(this._repository) : super(const AsyncValue.data(null));

  Future<bool> createEmployee({
    required String name,
    required String email,
    required String password,
    required String role,
    required String storeId,
    required String createdBy,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.createEmployee(
        name: name,
        email: email,
        password: password,
        role: role,
        storeId: storeId,
        createdBy: createdBy,
      );
    });
    state = result;
    return !result.hasError;
  }

  Future<bool> updateEmployee({
    required String uid,
    required String name,
    required String role,
    required String storeId,
    required String changedBy,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.updateEmployee(
        uid: uid,
        name: name,
        role: role,
        storeId: storeId,
        changedBy: changedBy,
      ),
    );
    return !state.hasError;
  }

  Future<bool> toggleActiveStatus({
    required String uid,
    required bool isActive,
    required String storeId,
    required String changedBy,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.toggleEmployeeActiveStatus(
        uid: uid,
        isActive: isActive,
        storeId: storeId,
        changedBy: changedBy,
      );
    });
    state = result;
    return !result.hasError;
  }
}

final employeeFormControllerProvider =
    StateNotifierProvider<EmployeeFormController, AsyncValue<void>>((ref) {
      return EmployeeFormController(ref.watch(employeeRepositoryProvider));
    });
