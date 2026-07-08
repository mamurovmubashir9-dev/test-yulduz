import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../routing/app_router.dart';
import '../../services/grading_service.dart';
import '../../widgets/circular_score_ring.dart';
import '../../widgets/fade_slide_in.dart';

class TestResultScreen extends StatefulWidget {
  final String testTitle;
  final TestGradeSummary summary;

  /// True when reopening an already-graded test from the dashboard just to
  /// review it, as opposed to landing here right after submitting — skips
  /// the confetti and swaps the closing action for a plain back navigation.
  final bool isReview;

  const TestResultScreen({
    super.key,
    required this.testTitle,
    required this.summary,
    this.isReview = false,
  });

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  late final ConfettiController _confetti = ConfettiController(duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    final grade = int.tryParse(widget.summary.gradeLabel) ?? 0;
    if (grade >= 4 && !widget.isReview) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _confetti.play();
      });
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Color get _gradeColor {
    switch (widget.summary.gradeLabel) {
      case '5':
        return AppColors.secondary;
      case '4':
        return AppColors.primary;
      case '3':
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }

  String get _gradeWord {
    switch (widget.summary.gradeLabel) {
      case '5':
        return 'A\'LO';
      case '4':
        return 'YAXSHI';
      case '3':
        return 'QONIQARLI';
      default:
        return 'QONIQARSIZ';
    }
  }

  void _share() {
    final summary = widget.summary;
    SharePlus.instance.share(ShareParams(text:
        '${widget.testTitle}\n'
        'Natija: ${summary.totalScore}/${summary.maxScore} ball (${summary.percentage.toStringAsFixed(0)}%)\n'
        'Baho: $_gradeWord (${summary.gradeLabel})\n'
        '\n"TestYulduz" orqali'));
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final correctCount = summary.questionResults.where((r) => r.isCorrect).length;
    final incorrectCount = summary.questionResults.length - correctCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Natija'),
        automaticallyImplyLeading: widget.isReview,
        actions: [
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Ulashish',
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(
                  widget.testTitle,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.palette.textSecondary),
                ),
                const SizedBox(height: 20),
                Center(child: CircularScoreRing(percentage: summary.percentage, color: _gradeColor)),
                const SizedBox(height: 20),
                Text(
                  '${summary.totalScore}/${summary.maxScore} ball',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    Text('Sizning bahoingiz',
                        style: TextStyle(color: context.palette.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      _gradeWord,
                      style: TextStyle(color: _gradeColor, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final grade = int.tryParse(summary.gradeLabel) ?? 0;
                        return Icon(
                          i < grade ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.warning,
                          size: 26,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'To\'g\'ri javoblar',
                        value: '$correctCount',
                        color: AppColors.secondary,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        label: 'Noto\'g\'ri javoblar',
                        value: '$incorrectCount',
                        color: AppColors.danger,
                        icon: Icons.cancel_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        label: 'Umumiy ball',
                        value: '${summary.totalScore}',
                        color: AppColors.primary,
                        icon: Icons.stars_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('Savollar bo\'yicha natija',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 10),
                for (final (i, result) in summary.questionResults.indexed)
                  FadeSlideIn(
                    index: i,
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          result.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: result.isCorrect ? AppColors.secondary : AppColors.danger,
                        ),
                        title: Text(result.question.questionText),
                        trailing: Text(
                          '${result.scoreEarned}/${result.question.points}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => widget.isReview
                      ? Navigator.of(context).pop()
                      : context.go(AppRoutes.studentDashboard),
                  child: Text(widget.isReview ? 'Yopish' : 'Bosh sahifaga qaytish'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              maxBlastForce: 12,
              minBlastForce: 6,
              emissionFrequency: 0.04,
              numberOfParticles: 18,
              gravity: 0.25,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.warning,
                AppColors.optionBlue,
                AppColors.optionPurple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}
