import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import '../core/theme/app_theme.dart';
import '../core/presentation/widgets/connectivity_banner.dart';

class SmartStockApp extends ConsumerWidget {
  const SmartStockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'SmartStock',

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      builder: (context, child) => ConnectivityBanner(child: child!),

      routerConfig: router,
    );
  }
}
