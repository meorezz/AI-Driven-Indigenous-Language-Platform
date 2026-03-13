import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Decorative leaf icons
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.eco,
                    size: 100,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  const Icon(
                    Icons.eco,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Indigenous\nLanguages',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Preserve. Learn. Connect.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                'Discover and help preserve the rich linguistic heritage of indigenous communities in Sabah and Sarawak through interactive learning.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 2),
              // Decorative nature elements
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.park, size: 20, color: AppColors.secondary.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Icon(Icons.eco, size: 16, color: AppColors.primary.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Icon(Icons.forest, size: 20, color: AppColors.secondary.withValues(alpha: 0.5)),
                ],
              ),
              const SizedBox(height: 24),
              // Begin Journey button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/region-select'),
                  child: const Text('Begin Journey'),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
