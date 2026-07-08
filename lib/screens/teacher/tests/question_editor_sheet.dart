import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/draft_question.dart';
import '../../../models/question.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';

/// Bottom sheet for creating or editing one [DraftQuestion] inside the test
/// builder. Returns the finished draft via [Navigator.pop], or null if
/// cancelled.
class QuestionEditorSheet extends StatefulWidget {
  final DraftQuestion? initial;

  const QuestionEditorSheet({super.key, this.initial});

  @override
  State<QuestionEditorSheet> createState() => _QuestionEditorSheetState();
}

class _QuestionEditorSheetState extends State<QuestionEditorSheet> {
  late QuestionType _type;
  late final TextEditingController _questionText;
  late final TextEditingController _points;
  late final TextEditingController _correctAnswerText;
  late List<DraftAnswer> _options;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = initial?.type ?? QuestionType.closed;
    _questionText = TextEditingController(text: initial?.questionText ?? '');
    _points = TextEditingController(text: (initial?.points ?? 1).toString());
    _correctAnswerText = TextEditingController(text: initial?.correctAnswerText ?? '');
    _options = (initial?.options ?? List.generate(4, (_) => DraftAnswer()))
        .map((o) => DraftAnswer(text: o.text, isCorrect: o.isCorrect))
        .toList();
  }

  @override
  void dispose() {
    _questionText.dispose();
    _points.dispose();
    _correctAnswerText.dispose();
    super.dispose();
  }

  void _save() {
    final points = int.tryParse(_points.text.trim()) ?? 0;
    final draft = DraftQuestion(
      questionText: _questionText.text.trim(),
      type: _type,
      points: points,
      correctAnswerText: _correctAnswerText.text.trim(),
      options: _options,
    );

    if (!draft.isValid) {
      final message = _type == QuestionType.closed
          ? 'Kamida 2 variant kiriting va to\'g\'ri javobni belgilang'
          : 'Savol matni, ball va to\'g\'ri javobni kiriting';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  widget.initial == null ? 'Yangi savol' : 'Savolni tahrirlash',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _questionText,
                  label: 'Savol matni',
                  icon: Icons.help_outline_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<QuestionType>(
                        segments: const [
                          ButtonSegment(value: QuestionType.closed, label: Text('Yopiq')),
                          ButtonSegment(value: QuestionType.open, label: Text('Ochiq')),
                        ],
                        selected: {_type},
                        onSelectionChanged: (s) => setState(() => _type = s.first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _points,
                  label: 'Ball',
                  icon: Icons.star_border_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                if (_type == QuestionType.closed) ..._buildOptions() else _buildOpenAnswer(),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Saqlash', onPressed: _save),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildOptions() {
    return [
      Text('Variantlar (to\'g\'ri javobni belgilang)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: context.palette.textSecondary)),
      const SizedBox(height: 10),
      for (var i = 0; i < _options.length; i++) _buildOptionRow(i),
    ];
  }

  Widget _buildOptionRow(int index) {
    final option = _options[index];
    final letter = String.fromCharCode('A'.codeUnitAt(0) + index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              option.isCorrect ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: option.isCorrect ? AppColors.secondary : context.palette.textSecondary,
            ),
            tooltip: 'To\'g\'ri javob sifatida belgilash',
            onPressed: () => setState(() {
              for (final o in _options) {
                o.isCorrect = false;
              }
              option.isCorrect = true;
            }),
          ),
          Expanded(
            child: TextFormField(
              initialValue: option.text,
              decoration: InputDecoration(labelText: 'Variant $letter'),
              onChanged: (v) => option.text = v,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenAnswer() {
    return AppTextField(
      controller: _correctAnswerText,
      label: 'To\'g\'ri javob matni',
      icon: Icons.check_circle_outline_rounded,
      maxLines: 2,
    );
  }
}
