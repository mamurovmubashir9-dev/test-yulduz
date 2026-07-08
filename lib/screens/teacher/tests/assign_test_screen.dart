import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/teacher_providers.dart';
import '../../../widgets/async_value_widget.dart';
import '../../../widgets/empty_view.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/search_field.dart';
import '../../../widgets/skeleton_list.dart';
import '../../../widgets/student_card.dart';

class AssignTestScreen extends ConsumerStatefulWidget {
  final int testId;

  const AssignTestScreen({super.key, required this.testId});

  @override
  ConsumerState<AssignTestScreen> createState() => _AssignTestScreenState();
}

class _AssignTestScreenState extends ConsumerState<AssignTestScreen> {
  final Set<int> _selected = {};
  final _searchController = TextEditingController();
  String _query = '';
  bool _submitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    final error = await ref.read(assignTestControllerProvider.notifier).assign(
          testId: widget.testId,
          studentIds: _selected.toList(),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test tanlangan o\'quvchilarga yuborildi')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(teacherStudentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('O\'quvchilarga yuborish')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchField(
              controller: _searchController,
              hint: 'O\'quvchi qidirish...',
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: AsyncValueWidget(
              value: studentsAsync,
              onRetry: () => ref.invalidate(teacherStudentsProvider),
              loading: () => const SkeletonList(),
              data: (allStudents) {
                if (allStudents.isEmpty) {
                  return const EmptyView(
                    message: 'Avval o\'quvchi qo\'shing',
                    icon: Icons.groups_outlined,
                  );
                }
                final students = _query.isEmpty
                    ? allStudents
                    : allStudents
                        .where((s) =>
                            s.fullname.toLowerCase().contains(_query) ||
                            s.username.toLowerCase().contains(_query))
                        .toList();
                if (students.isEmpty) {
                  return const EmptyView(message: 'Hech narsa topilmadi', icon: Icons.search_off_rounded);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: students.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return FadeSlideIn(
                      index: index,
                      child: StudentCard(
                        student: student,
                        selected: _selected.contains(student.id),
                        onSelectChanged: (checked) => setState(() {
                          if (checked) {
                            _selected.add(student.id);
                          } else {
                            _selected.remove(student.id);
                          }
                        }),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: PrimaryButton(
            label: 'Yuborish (${_selected.length})',
            onPressed: _selected.isEmpty ? null : _submit,
            loading: _submitting,
          ),
        ),
      ),
    );
  }
}
