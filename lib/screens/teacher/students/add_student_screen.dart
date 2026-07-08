import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/teacher_providers.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullname = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _fullname.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final error = await ref.read(addStudentControllerProvider.notifier).addStudent(
          fullname: _fullname.text.trim(),
          username: _username.text.trim(),
          password: _password.text,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('O\'quvchi muvaffaqiyatli qo\'shildi')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('O\'quvchi qo\'shish')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _fullname,
                  label: 'F.I.O',
                  icon: Icons.badge_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'F.I.O ni kiriting' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _username,
                  label: 'Login',
                  icon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Loginni kiriting';
                    if (v.trim().contains(' ')) return 'Loginda probel bo\'lmasin';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _password,
                  label: 'Parol',
                  icon: Icons.lock_outline_rounded,
                  validator: (v) =>
                      (v == null || v.length < 4) ? 'Parol kamida 4 belgidan iborat bo\'lsin' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Saqlash', onPressed: _submit, loading: _submitting),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
