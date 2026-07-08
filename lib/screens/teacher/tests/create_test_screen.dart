import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/answer.dart';
import '../../../models/draft_question.dart';
import '../../../models/question.dart';
import '../../../providers/teacher_providers.dart';
import '../../../providers/test_taking_provider.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/empty_view.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/loading_view.dart';
import '../../../widgets/primary_button.dart';
import 'question_editor_sheet.dart';

/// Test builder screen, doubling as the editor for an existing test.
///
/// Editing loads the test's current questions/answers through
/// [testTakingDataProvider] (the same data the student-facing test-taking
/// screen uses) and converts them back into [DraftQuestion]s so they can be
/// reused in the same form as creation.
class CreateTestScreen extends ConsumerWidget {
  final int? testId;

  const CreateTestScreen({super.key, this.testId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testId = this.testId;
    if (testId == null) {
      return const _TestForm(testId: null, initialTitle: '', initialDescription: '', initialQuestions: []);
    }

    final dataAsync = ref.watch(testTakingDataProvider(testId));
    return dataAsync.when(
      loading: () => Scaffold(appBar: AppBar(title: const Text('Testni tahrirlash')), body: const LoadingView()),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Testni tahrirlash')),
        body: ErrorView(onRetry: () => ref.invalidate(testTakingDataProvider(testId))),
      ),
      data: (data) => _TestForm(
        testId: testId,
        initialTitle: data.test.title,
        initialDescription: data.test.description,
        initialQuestions: [
          for (final question in data.questions)
            DraftQuestion(
              questionText: question.questionText,
              type: question.questionType,
              points: question.points,
              correctAnswerText: question.correctAnswerText ?? '',
              options: question.questionType == QuestionType.closed
                  ? [
                      for (final answer in data.answersByQuestion[question.id] ?? const <Answer>[])
                        DraftAnswer(text: answer.answerText, isCorrect: answer.isCorrect),
                    ]
                  : null,
            ),
        ],
      ),
    );
  }
}

class _TestForm extends ConsumerStatefulWidget {
  final int? testId;
  final String initialTitle;
  final String initialDescription;
  final List<DraftQuestion> initialQuestions;

  const _TestForm({
    required this.testId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialQuestions,
  });

  @override
  ConsumerState<_TestForm> createState() => _TestFormState();
}

class _TestFormState extends ConsumerState<_TestForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initialTitle);
  late final _description = TextEditingController(text: widget.initialDescription);
  late final List<DraftQuestion> _questions = List.of(widget.initialQuestions);
  bool _submitting = false;

  bool get _isEditing => widget.testId != null;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _openEditor({DraftQuestion? initial, int? index}) async {
    final result = await showModalBottomSheet<DraftQuestion>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => QuestionEditorSheet(initial: initial),
    );

    if (result == null) return;
    setState(() {
      if (index != null) {
        _questions[index] = result;
      } else {
        _questions.add(result);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamida bitta savol qo\'shing')),
      );
      return;
    }

    setState(() => _submitting = true);
    final testId = widget.testId;
    final error = testId == null
        ? await ref.read(createTestControllerProvider.notifier).createTest(
              title: _title.text.trim(),
              description: _description.text.trim(),
              questions: _questions,
            )
        : await ref.read(editTestControllerProvider.notifier).editTest(
              testId: testId,
              title: _title.text.trim(),
              description: _description.text.trim(),
              questions: _questions,
            );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Test yangilandi' : 'Test muvaffaqiyatli yaratildi')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Testni tahrirlash' : 'Test yaratish')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _title,
                      label: 'Test nomi',
                      icon: Icons.title_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Test nomini kiriting' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _description,
                      label: 'Tavsif (ixtiyoriy)',
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 4),
                child: Row(
                  children: [
                    Text('Savollar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: _questions.isEmpty
                    ? const EmptyView(
                        message: 'Hali savol qo\'shilmagan',
                        icon: Icons.help_outline_rounded,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        itemCount: _questions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final q = _questions[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(child: Text('${index + 1}')),
                              title: Text(
                                q.questionText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${q.type == QuestionType.closed ? "Yopiq" : "Ochiq"} · ${q.points} ball',
                                style: TextStyle(color: context.palette.textSecondary),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _openEditor(initial: q, index: index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                    onPressed: () => setState(() => _questions.removeAt(index)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: OutlinedButton.icon(
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Savol qo\'shish'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: PrimaryButton(
                  label: _isEditing ? 'O\'zgarishlarni saqlash' : 'Testni saqlash',
                  onPressed: _submit,
                  loading: _submitting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
