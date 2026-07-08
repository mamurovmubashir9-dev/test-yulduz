import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_view.dart';
import 'loading_view.dart';

/// Collapses the common `AsyncValue.when(loading/error/data)` boilerplate
/// used across the screens that read a `FutureProvider`.
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final Widget Function()? loading;

  const AsyncValueWidget({super.key, required this.value, required this.data, this.onRetry, this.loading});

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: loading ?? () => const LoadingView(),
      error: (error, _) => ErrorView(onRetry: onRetry),
    );
  }
}
