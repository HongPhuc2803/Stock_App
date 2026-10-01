// go_router builders require two callback parameters even when a screen does
// not consume either value.
// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/customers/presentation/screens/add_customer_screen.dart';
import '../features/customers/presentation/screens/customer_detail_screen.dart';
import '../features/customers/presentation/screens/customer_list_screen.dart';
import '../features/dashboard/presentation/screens/owner_dashboard_screen.dart';
import '../features/employees/presentation/screens/add_employee_screen.dart';
import '../features/employees/presentation/screens/employee_list_screen.dart';
import '../features/inventory/presentation/screens/adjust_stock_screen.dart';
import '../features/inventory/presentation/screens/inventory_history_screen.dart';
import '../features/inventory/presentation/screens/inventory_management_screen.dart';
import '../features/inventory/presentation/screens/receive_stock_screen.dart';
import '../features/inventory/presentation/screens/warehouse_home_screen.dart';
import '../features/notifications/presentation/screens/notification_center_screen.dart';
import '../features/orders/presentation/screens/order_detail_screen.dart';
import '../features/orders/presentation/screens/order_history_screen.dart';
import '../features/pos/presentation/screens/pos_screen.dart';
import '../features/pos/presentation/screens/staff_home_screen.dart';
import '../features/products/presentation/screens/add_product_screen.dart';
import '../features/products/presentation/screens/category_management_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';
import '../features/reports/presentation/screens/reports_screen.dart';
import '../features/settings/presentation/screens/profile_settings_screen.dart';
import '../features/settings/presentation/screens/notification_preferences_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/store_settings_screen.dart';
import 'role_navigation_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final publicRoutes = {'/login', '/register', '/forgot-password'};
      final isPublic = publicRoutes.contains(state.matchedLocation);

      // Firebase Auth is the immediate source of truth for session presence.
      // After signOut() completes currentUser is null synchronously, while the
      // Riverpod profile stream can still briefly contain the previous user.
      if (ref.read(firebaseAuthProvider).currentUser == null) {
        return isPublic ? null : '/login';
      }

      if (authState.isLoading) return state.matchedLocation == '/' ? null : '/';

      final user = authState.value;
      if (user == null) return isPublic ? null : '/login';

      if (!user.isActive) {
        Future<void>.microtask(ref.read(authRepositoryProvider).logout);
        return '/login';
      }

      final role = user.role.toUpperCase();
      final home = homeRouteForRole(role);
      if (home == '/login') {
        Future<void>.microtask(ref.read(authRepositoryProvider).logout);
        return state.matchedLocation == '/login' ? null : '/login';
      }
      if (state.matchedLocation == '/' || isPublic) return home;
      if (state.matchedLocation.startsWith('/owner') && role != 'OWNER') {
        return home;
      }
      if (state.matchedLocation.startsWith('/staff') && role != 'STAFF') {
        return home;
      }
      if (state.matchedLocation.startsWith('/warehouse') &&
          role != 'WAREHOUSE_MANAGER') {
        return home;
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Không tìm thấy trang')),
      body: Center(
        child: FilledButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.home_outlined),
          label: const Text('Về trang chủ'),
        ),
      ),
    ),
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => RoleNavigationShell(
          role: AppRole.owner,
          location: state.uri.path,
          child: child,
        ),
        routes: _ownerRoutes,
      ),
      ShellRoute(
        builder: (context, state, child) => RoleNavigationShell(
          role: AppRole.staff,
          location: state.uri.path,
          child: child,
        ),
        routes: _staffRoutes,
      ),
      ShellRoute(
        builder: (context, state, child) => RoleNavigationShell(
          role: AppRole.warehouse,
          location: state.uri.path,
          child: child,
        ),
        routes: _warehouseRoutes,
      ),
    ],
  );

  // Keep the same GoRouter instance for the lifetime of the provider and ask
  // it to re-run redirect whenever Firebase authentication/profile changes.
  // Recreating routerConfig on logout can leave the currently rendered role
  // shell on screen, especially when logout is triggered from an app-bar
  // button that does not navigate explicitly.
  ref.listen(authStateChangesProvider, (_, __) {
    router.refresh();
  });
  ref.onDispose(router.dispose);

  return router;
});

final List<RouteBase> _ownerRoutes = [
  GoRoute(
    path: '/owner/dashboard',
    builder: (_, __) => const OwnerDashboardScreen(),
  ),
  GoRoute(
    path: '/owner/products',
    builder: (_, __) => const ProductListScreen(),
  ),
  GoRoute(
    path: '/owner/categories',
    builder: (_, __) => const CategoryManagementScreen(),
  ),
  GoRoute(
    path: '/owner/products/create',
    builder: (_, __) => const AddProductScreen(),
  ),
  GoRoute(
    path: '/owner/products/:id',
    builder: (_, state) => ProductDetailScreen(
      productId: state.pathParameters['id'] ?? '',
      allowManagement: true,
    ),
  ),
  GoRoute(
    path: '/owner/products/edit/:id',
    builder: (_, state) =>
        AddProductScreen(productId: state.pathParameters['id']),
  ),
  GoRoute(path: '/owner/pos', builder: (_, __) => const PosScreen()),
  GoRoute(
    path: '/owner/inventory',
    builder: (_, __) => const InventoryManagementScreen(),
  ),
  GoRoute(
    path: '/owner/inventory/receive',
    builder: (_, __) => const ReceiveStockScreen(),
  ),
  GoRoute(
    path: '/owner/inventory/adjust',
    builder: (_, __) => const AdjustStockScreen(),
  ),
  GoRoute(
    path: '/owner/inventory/history',
    builder: (_, __) => const InventoryHistoryScreen(),
  ),
  GoRoute(
    path: '/owner/orders',
    builder: (_, __) => const OrderHistoryScreen(),
  ),
  GoRoute(
    path: '/owner/orders/details/:id',
    builder: (_, state) =>
        OrderDetailScreen(orderId: state.pathParameters['id'] ?? ''),
  ),
  GoRoute(path: '/owner/reports', builder: (_, __) => const ReportsScreen()),
  GoRoute(
    path: '/owner/employees',
    builder: (_, __) => const EmployeeListScreen(),
  ),
  GoRoute(
    path: '/owner/employees/create',
    builder: (_, __) => const AddEmployeeScreen(),
  ),
  GoRoute(
    path: '/owner/customers',
    builder: (_, __) => const CustomerListScreen(),
  ),
  GoRoute(
    path: '/owner/customers/create',
    builder: (_, __) => const AddCustomerScreen(),
  ),
  GoRoute(
    path: '/owner/customers/edit/:id',
    builder: (_, state) =>
        AddCustomerScreen(customerId: state.pathParameters['id']),
  ),
  GoRoute(
    path: '/owner/customers/details/:id',
    builder: (_, state) =>
        CustomerDetailScreen(customerId: state.pathParameters['id'] ?? ''),
  ),
  GoRoute(path: '/owner/profile', builder: (_, __) => const SettingsScreen()),
  GoRoute(path: '/owner/settings', builder: (_, __) => const SettingsScreen()),
  GoRoute(
    path: '/owner/settings/profile',
    builder: (_, __) => const ProfileSettingsScreen(),
  ),
  GoRoute(
    path: '/owner/settings/store',
    builder: (_, __) => const StoreSettingsScreen(),
  ),
  GoRoute(
    path: '/owner/settings/notifications',
    builder: (_, __) => const NotificationPreferencesScreen(),
  ),
  GoRoute(
    path: '/owner/notifications',
    builder: (_, __) => const NotificationCenterScreen(),
  ),
];

final List<RouteBase> _staffRoutes = [
  GoRoute(path: '/staff/home', builder: (_, __) => const StaffHomeScreen()),
  GoRoute(path: '/staff/pos', builder: (_, __) => const PosScreen()),
  GoRoute(
    path: '/staff/products',
    builder: (_, __) => const ProductListScreen(allowManagement: false),
  ),
  GoRoute(
    path: '/staff/products/:id',
    builder: (_, state) =>
        ProductDetailScreen(productId: state.pathParameters['id'] ?? ''),
  ),
  GoRoute(
    path: '/staff/orders',
    builder: (_, __) => const OrderHistoryScreen(),
  ),
  GoRoute(
    path: '/staff/orders/details/:id',
    builder: (_, state) =>
        OrderDetailScreen(orderId: state.pathParameters['id'] ?? ''),
  ),
  GoRoute(
    path: '/staff/customers',
    builder: (_, __) => const CustomerListScreen(),
  ),
  GoRoute(
    path: '/staff/customers/create',
    builder: (_, __) => const AddCustomerScreen(),
  ),
  GoRoute(
    path: '/staff/customers/edit/:id',
    builder: (_, state) =>
        AddCustomerScreen(customerId: state.pathParameters['id']),
  ),
  GoRoute(
    path: '/staff/customers/details/:id',
    builder: (_, state) =>
        CustomerDetailScreen(customerId: state.pathParameters['id'] ?? ''),
  ),
  GoRoute(path: '/staff/profile', builder: (_, __) => const SettingsScreen()),
  GoRoute(path: '/staff/settings', builder: (_, __) => const SettingsScreen()),
  GoRoute(
    path: '/staff/settings/profile',
    builder: (_, __) => const ProfileSettingsScreen(),
  ),
  GoRoute(
    path: '/staff/settings/notifications',
    builder: (_, __) => const NotificationPreferencesScreen(),
  ),
  GoRoute(
    path: '/staff/notifications',
    builder: (_, __) => const NotificationCenterScreen(),
  ),
];

final List<RouteBase> _warehouseRoutes = [
  GoRoute(
    path: '/warehouse/home',
    builder: (_, __) => const WarehouseHomeScreen(),
  ),
  GoRoute(
    path: '/warehouse/inventory',
    builder: (_, __) => const InventoryManagementScreen(),
  ),
  GoRoute(
    path: '/warehouse/receive-stock',
    builder: (_, __) => const ReceiveStockScreen(),
  ),
  GoRoute(
    path: '/warehouse/adjust-stock',
    builder: (_, __) => const AdjustStockScreen(),
  ),
  GoRoute(
    path: '/warehouse/history',
    builder: (_, __) => const InventoryHistoryScreen(),
  ),
  GoRoute(
    path: '/warehouse/profile',
    builder: (_, __) => const SettingsScreen(),
  ),
  GoRoute(
    path: '/warehouse/inventory/receive',
    redirect: (_, __) => '/warehouse/receive-stock',
  ),
  GoRoute(
    path: '/warehouse/inventory/adjust',
    redirect: (_, __) => '/warehouse/adjust-stock',
  ),
  GoRoute(
    path: '/warehouse/settings',
    builder: (_, __) => const SettingsScreen(),
  ),
  GoRoute(
    path: '/warehouse/settings/profile',
    builder: (_, __) => const ProfileSettingsScreen(),
  ),
  GoRoute(
    path: '/warehouse/settings/notifications',
    builder: (_, __) => const NotificationPreferencesScreen(),
  ),
  GoRoute(
    path: '/warehouse/notifications',
    builder: (_, __) => const NotificationCenterScreen(),
  ),
];

String homeRouteForRole(String role) => switch (role) {
  'OWNER' => '/owner/dashboard',
  'STAFF' => '/staff/home',
  'WAREHOUSE_MANAGER' => '/warehouse/home',
  _ => '/login',
};
