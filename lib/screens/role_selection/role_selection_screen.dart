import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../routing/app_router.dart';
import '../../widgets/blob_backdrop.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/role_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlobBackdrop(
                size: 128,
                colors: const [AppColors.primary, AppColors.secondary, AppColors.optionYellow],
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kim sifatida davom etasiz?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Davom etish uchun rolingizni tanlang',
                style: TextStyle(color: context.palette.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 32),
              FadeSlideIn(
                index: 0,
                child: RoleCard(
                  title: 'O\'qituvchi',
                  subtitle: 'Test yarating va o\'quvchilarni boshqaring',
                  icon: Icons.co_present_rounded,
                  gradient: const [Color(0xFF3B3E63), Color(0xFF23253F)],
                  onTap: () => context.push(AppRoutes.teacherLogin),
                ),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                index: 1,
                child: RoleCard(
                  title: 'O\'quvchi',
                  subtitle: 'Testlarni yeching, natijalarni ko\'ring',
                  icon: Icons.backpack_rounded,
                  gradient: const [Color(0xFF22C58B), Color(0xFF10A374)],
                  onTap: () => context.push(AppRoutes.studentLogin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
