import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartstock/app/role_navigation_shell.dart';
import 'package:smartstock/core/errors/user_error_message.dart';
import 'package:smartstock/core/formatters/app_formatters.dart';
import 'package:smartstock/core/presentation/widgets/async_state_view.dart';

void main() {
  test('VND formatter uses no decimal places', () {
    expect(defaultAppFormatters.money(125000), contains('125.000'));
    expect(defaultAppFormatters.money(125000), contains('₫'));
  });

  test('unknown technical errors are hidden', () {
    const secret = 'internal stack and collection path';
    final message = userErrorMessage(Exception(secret));
    expect(message, isNot(contains(secret)));
    expect(message, 'Đã xảy ra lỗi. Vui lòng thử lại.');
  });

  testWidgets('async state renders empty and retry states', (tester) async {
    AsyncValue<List<int>> value = const AsyncValue.data([]);

    Widget app() => MaterialApp(
      home: AsyncStateView<List<int>>(
        value: value,
        isEmpty: (items) => items.isEmpty,
        emptyTitle: 'Danh sách trống',
        onRetry: () {},
        data: (_) => const Text('Nội dung'),
      ),
    );

    await tester.pumpWidget(app());
    expect(find.text('Danh sách trống'), findsOneWidget);

    value = AsyncValue.error(Exception('secret'), StackTrace.empty);
    await tester.pumpWidget(app());
    expect(find.text('Thử lại'), findsOneWidget);
    expect(find.textContaining('secret'), findsNothing);
  });

  testWidgets('role navigation adapts between mobile and tablet', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    Widget app() => const MaterialApp(
      home: RoleNavigationShell(
        role: AppRole.owner,
        location: '/owner/dashboard',
        child: SizedBox.expand(),
      ),
    );

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(app());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    tester.view.physicalSize = const Size(1024, 768);
    await tester.pumpWidget(app());
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
