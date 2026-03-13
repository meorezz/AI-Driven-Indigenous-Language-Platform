import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NativeIntentScreen extends ConsumerWidget {
  const NativeIntentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.lightGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'How would you\nlike to help?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerif(
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _IntentOption(
                      title: 'Explore the language',
                      subtitle: 'Learn and discover',
                      onTap: () => context.go('/home'),
                    ),
                    const _DiamondDivider(),
                    _IntentOption(
                      title: 'Help preserve the language',
                      subtitle: 'Contribute',
                      onTap: () => context.go('/contribute'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _IntentOption({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textDarkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiamondDivider extends StatelessWidget {
  const _DiamondDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.textDark.withValues(alpha: 0.10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Transform.rotate(
            angle: 0.785398, // 45 degrees
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textDark.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.textDark.withValues(alpha: 0.10),
          ),
        ),
      ],
    );
  }
}
