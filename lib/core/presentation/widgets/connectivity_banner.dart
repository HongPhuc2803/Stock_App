import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(connectivityProvider).value;
    final offline =
        results != null &&
        (results.isEmpty ||
            results.every((item) => item == ConnectivityResult.none));

    return Column(
      children: [
        if (offline)
          Material(
            color: Theme.of(context).colorScheme.errorContainer,
            child: SafeArea(
              bottom: false,
              child: Semantics(
                liveRegion: true,
                child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      'Đang ngoại tuyến — dữ liệu có thể chưa được cập nhật.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
