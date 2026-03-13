import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class UserLevelScreen extends ConsumerWidget {
  const UserLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Relationship')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is your relationship\nto this language?',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This helps us personalize your experience.',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            _LevelOptionCard(
              icon: Icons.school,
              title: "I'm new to this language",
              subtitle: 'Beginner',
              onTap: () {
                ref.read(userLevelProvider.notifier).state = 'beginner';
                context.go('/home');
              },
            ),
            const SizedBox(height: 16),
            _LevelOptionCard(
              icon: Icons.hearing,
              title: "I've heard or used it a little",
              subtitle: 'Intermediate',
              onTap: () {
                ref.read(userLevelProvider.notifier).state = 'intermediate';
                context.go('/quick-check');
              },
            ),
            const SizedBox(height: 16),
            _LevelOptionCard(
              icon: Icons.favorite,
              title: 'I grew up with this language',
              subtitle: 'Native Speaker',
              onTap: () {
                ref.read(userLevelProvider.notifier).state = 'native';
                context.go('/native-intent');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LevelOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
