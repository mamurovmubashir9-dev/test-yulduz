import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/student_providers.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import 'test_result_screen.dart';

/// Reopens a test the student already completed, re-grading it from the
/// stored answers so they can review what they got right or wrong.
class TestReviewScreen extends ConsumerWidget {
  final int studentTestId;

  const TestReviewScreen({super.key, required this.studentTestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(completedTestReviewProvider(studentTestId));

    return reviewAsync.when(
      data: (review) => TestResultScreen(
        testTitle: review.test.title,
        summary: review.summary,
        isReview: true,
      ),
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Natija')),
        body: ErrorView(
          message: 'Natijani yuklashda xatolik yuz berdi',
          onRetry: () => ref.invalidate(completedTestReviewProvider(studentTestId)),
        ),
      ),
    );
  }
}
