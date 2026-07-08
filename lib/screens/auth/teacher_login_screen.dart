import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/primary_button.dart';

class TeacherLoginScreen extends ConsumerStatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  ConsumerState<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends ConsumerState<TeacherLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final error = await ref
        .read(authControllerProvider.notifier)
        .loginTeacher(_username.text.trim(), _password.text);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BackButton(),
                const SizedBox(height: 8),
                const AuthHeader(
                  icon: Icons.co_present_rounded,
                  title: 'O\'qituvchi kirishi',
                  subtitle: 'Hisobingizga kirish uchun login va parolni kiriting',
                  gradient: [Color(0xFF3B3E63), Color(0xFF23253F)],
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _username,
                  label: 'Login',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Loginni kiriting' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _password,
                  label: 'Parol',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: (v) => (v == null || v.isEmpty) ? 'Parolni kiriting' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Kirish', onPressed: _submit, loading: _submitting),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Faqat o\'qituvchilar uchun',
                    style: TextStyle(color: context.palette.textSecondary.withValues(alpha: 0.8), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
