import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../errors/user_error_message.dart';

class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    required this.value,
    required this.data,
    required this.isEmpty,
    required this.onRetry,
    this.emptyTitle = 'Chưa có dữ liệu',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.loadingLabel = 'Đang tải dữ liệu',
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final bool Function(T value) isEmpty;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final String loadingLabel;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => Center(
        child: Semantics(
          label: loadingLabel,
          liveRegion: true,
          child: const CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) =>
          _ErrorState(message: userErrorMessage(error), onRetry: onRetry),
      data: (result) => isEmpty(result)
          ? _EmptyState(
              title: emptyTitle,
              message: emptyMessage,
              icon: emptyIcon,
            )
          : data(result),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.icon, this.message});

  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: message == null ? title : '$title. $message',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (message case final text?) ...[
              const SizedBox(height: 6),
              Text(text, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    ),
  );
}
