import 'package:firebase_auth/firebase_auth.dart';

/// Converts infrastructure errors into stable, user-facing messages.
String userErrorMessage(Object error) {
  final code = switch (error) {
    FirebaseAuthException exception => exception.code,
    FirebaseException exception => exception.code,
    _ => null,
  };

  return switch (code) {
    'permission-denied' ||
    'unauthorized' => 'Bạn không có quyền thực hiện thao tác này.',
    'unavailable' || 'network-request-failed' || 'retry-limit-exceeded' =>
      'Không thể kết nối. Hãy kiểm tra mạng và thử lại.',
    'not-found' || 'object-not-found' => 'Dữ liệu không còn tồn tại.',
    'already-exists' ||
    'email-already-in-use' => 'Thông tin này đã được sử dụng.',
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Thông tin đăng nhập không chính xác.',
    'too-many-requests' => 'Bạn thao tác quá nhanh. Vui lòng thử lại sau.',
    _ => 'Đã xảy ra lỗi. Vui lòng thử lại.',
  };
}
