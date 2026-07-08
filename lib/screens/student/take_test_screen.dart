import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/answer.dart';
import '../../models/question.dart';
import '../../models/student_test.dart';
import '../../providers/student_providers.dart';
import '../../providers/test_taking_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/primary_button.dart';
import 'test_result_screen.dart';

class TakeTestScreen extends ConsumerStatefulWidget {
  final int studentTestId;
  final int testId;

  const TakeTestScreen({super.key, required this.studentTestId, required this.testId});

  @override
  ConsumerState<TakeTestScreen> createState() => _TakeTestScreenState();
}

class _TakeTestScreenState extends ConsumerState<TakeTestScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _confirmAndSubmit(TestTakingData data, StudentTest studentTest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Testni yakunlash'),
        content: const Text('Javoblaringizni tekshirib bo\'ldingizmi? Yakunlagandan so\'ng o\'zgartira olmaysiz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yakunlash')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    final responses = ref.read(testResponsesProvider);
    final summary = await ref.read(submitTestControllerProvider.notifier).submit(
          studentTest: studentTest,
          data: data,
          responses: responses,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (summary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Natijani saqlashda xatolik yuz berdi')),
      );
      return;
    }

    ref.read(testResponsesProvider.notifier).reset();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TestResultScreen(testTitle: data.test.title, summary: summary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(testTakingDataProvider(widget.testId));
    final studentTestAsync = ref.watch(studentTestByIdProvider(widget.studentTestId));

    return Scaffold(
      appBar: AppBar(title: Text(dataAsync.valueOrNull?.test.title ?? 'Test')),
      body: SafeArea(
        child: dataAsync.when(
          loading: () => const LoadingView(),
          error: (_, _) => const ErrorView(message: 'Testni yuklashda xatolik yuz berdi'),
          data: (data) {
            if (data.questions.isEmpty) {
              return const ErrorView(message: 'Bu testda hali savollar yo\'q');
            }
            return studentTestAsync.when(
              loading: () => const LoadingView(),
              error: (_, _) => const ErrorView(),
              data: (studentTest) {
                if (studentTest == null) {
                  return const ErrorView(message: 'Topshiriq topilmadi');
                }
                return _buildExam(data, studentTest);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildExam(TestTakingData data, StudentTest studentTest) {
    final questions = data.questions;
    final responses = ref.watch(testResponsesProvider);
    final isLast = _currentIndex == questions.length - 1;
    final answeredCount = questions.where((q) => responses[q.id] != null).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Savol ${_currentIndex + 1} / ${questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('Javob berildi: $answeredCount/${questions.length}',
                  style: TextStyle(color: context.palette.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / questions.length,
              minHeight: 6,
              backgroundColor: context.palette.border,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: questions.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final question = questions[index];
              return _QuestionPage(
                key: ValueKey(question.id),
                question: question,
                options: data.answersByQuestion[question.id] ?? const [],
                initialValue: responses[question.id],
                onChanged: (value) =>
                    ref.read(testResponsesProvider.notifier).setAnswer(question.id, value),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _goTo(_currentIndex - 1),
                    child: const Text('Oldingi'),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: isLast
                    ? PrimaryButton(
                        label: 'Yakunlash',
                        loading: _submitting,
                        onPressed: () => _confirmAndSubmit(data, studentTest),
                      )
                    : PrimaryButton(
                        label: 'Keyingi',
                        onPressed: () => _goTo(_currentIndex + 1),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestionPage extends StatefulWidget {
  final Question question;
  final List<Answer> options;
  final dynamic initialValue;
  final ValueChanged<dynamic> onChanged;

  const _QuestionPage({
    super.key,
    required this.question,
    required this.options,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<_QuestionPage> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue as String? ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.question.questionText,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text('${widget.question.points} ball',
                      style: TextStyle(color: context.palette.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (widget.question.questionType == QuestionType.closed)
            _buildOptionsGrid()
          else
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Javobingiz',
                alignLabelWithHint: true,
              ),
              onChanged: widget.onChanged,
            ),
        ],
      ),
    );
  }

  static const _optionColors = [
    AppColors.optionRed,
    AppColors.optionBlue,
    AppColors.optionYellow,
    AppColors.optionPurple,
  ];

  Widget _buildOptionsGrid() {
    final selectedId = widget.initialValue as int?;
    final hasSelection = selectedId != null;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final option = widget.options[index];
        final isSelected = selectedId == option.id;
        return _OptionTile(
          letter: String.fromCharCode('A'.codeUnitAt(0) + index),
          text: option.answerText,
          color: _optionColors[index % _optionColors.length],
          selected: isSelected,
          dimmed: hasSelection && !isSelected,
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onChanged(option.id);
          },
        );
      },
    );
  }
}

class _OptionTile extends StatefulWidget {
  final String letter;
  final String text;
  final Color color;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  const _OptionTile({
    required this.letter,
    required this.text,
    required this.color,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: widget.dimmed ? 0.5 : 1,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : (widget.selected ? 1.03 : 1),
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(18),
                border: widget.selected ? Border.all(color: Colors.white, width: 3) : null,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.letter,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                  if (widget.selected)
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
