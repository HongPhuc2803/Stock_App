import '../entities/employee.dart';

abstract class EmployeeRepository {
  Stream<List<Employee>> getEmployees(String storeId);
  Future<void> createEmployee({
    required String name,
    required String email,
    required String password,
    required String role,
    required String storeId,
    required String createdBy,
  });
  Future<void> toggleEmployeeActiveStatus({
    required String uid,
    required bool isActive,
    required String storeId,
    required String changedBy,
  });
  Future<void> updateEmployee({
    required String uid,
    required String name,
    required String role,
    required String storeId,
    required String changedBy,
  });
}
