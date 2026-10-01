import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRole { owner, staff, warehouse }

class RoleNavigationShell extends StatelessWidget {
  const RoleNavigationShell({
    required this.role,
    required this.location,
    required this.child,
    super.key,
  });

  final AppRole role;
  final String location;
  final Widget child;

  static const _ownerDestinations = [
    _Destination('Tổng quan', Icons.dashboard_outlined, '/owner/dashboard'),
    _Destination('Sản phẩm', Icons.inventory_2_outlined, '/owner/products'),
    _Destination('Kho', Icons.warehouse_outlined, '/owner/inventory'),
    _Destination('Đơn hàng', Icons.receipt_long_outlined, '/owner/orders'),
    _Destination('Hồ sơ', Icons.person_outline, '/owner/profile'),
  ];

  static const _staffDestinations = [
    _Destination('Trang chủ', Icons.home_outlined, '/staff/home'),
    _Destination('POS', Icons.point_of_sale_outlined, '/staff/pos'),
    _Destination('Đơn hàng', Icons.receipt_long_outlined, '/staff/orders'),
    _Destination('Sản phẩm', Icons.inventory_2_outlined, '/staff/products'),
    _Destination('Hồ sơ', Icons.person_outline, '/staff/profile'),
  ];

  static const _warehouseDestinations = [
    _Destination('Trang chủ', Icons.home_outlined, '/warehouse/home'),
    _Destination('Kho', Icons.inventory_outlined, '/warehouse/inventory'),
    _Destination(
      'Nhập hàng',
      Icons.add_box_outlined,
      '/warehouse/receive-stock',
    ),
    _Destination('Lịch sử', Icons.history, '/warehouse/history'),
    _Destination('Hồ sơ', Icons.person_outline, '/warehouse/profile'),
  ];

  List<_Destination> get _destinations => switch (role) {
    AppRole.owner => _ownerDestinations,
    AppRole.staff => _staffDestinations,
    AppRole.warehouse => _warehouseDestinations,
  };

  int get _selectedIndex {
    if (location.contains('/profile') || location.contains('/settings')) {
      return _destinations.length - 1;
    }
    if (role == AppRole.warehouse && location == '/warehouse/adjust-stock') {
      return 1;
    }
    final matches = <({int index, int length})>[];
    for (var index = 0; index < _destinations.length; index++) {
      final route = _destinations[index].route;
      if (location == route || location.startsWith('$route/')) {
        matches.add((index: index, length: route.length));
      }
    }
    if (matches.isEmpty) return 0;
    matches.sort((a, b) => b.length.compareTo(a.length));
    return matches.first.index;
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations;
    void navigate(int index) => context.go(destinations[index].route);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 840;
        return Scaffold(
          body: useRail
              ? Row(
                  children: [
                    SafeArea(
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        labelType: NavigationRailLabelType.all,
                        onDestinationSelected: navigate,
                        destinations: [
                          for (final destination in destinations)
                            NavigationRailDestination(
                              icon: Icon(destination.icon),
                              label: Text(destination.label),
                            ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: child),
                  ],
                )
              : child,
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: navigate,
                  destinations: [
                    for (final destination in destinations)
                      NavigationDestination(
                        icon: Icon(destination.icon),
                        label: destination.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
