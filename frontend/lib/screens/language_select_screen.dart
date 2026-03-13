import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class LanguageSelectScreen extends ConsumerWidget {
  const LanguageSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagesAsync = ref.watch(languagesProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: languagesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.textCream),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48,
                        color: AppColors.textCream.withValues(alpha: 0.7)),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load languages',
                      style: GoogleFonts.notoSerif(
                        fontSize: 18,
                        color: AppColors.textCream,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerif(
                        fontSize: 14,
                        color: AppColors.textCream.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => ref.invalidate(languagesProvider),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.notoSerif(
                          fontSize: 16,
                          color: AppColors.textCream,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textCream,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (languages) => Column(
              children: [
                const SizedBox(height: 40),

                // Back button + header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/region-select'),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.textCream.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      const Spacer(),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  'Select Language',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerif(
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textCream,
                    letterSpacing: 1.5,
                  ),
                ),

                if (selectedRegion != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Languages of ${selectedRegion.name}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSerif(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textCream.withValues(alpha: 0.6),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Language list
                Expanded(
                  child: languages.isEmpty
                      ? Center(
                          child: Text(
                            'No languages found for this region.',
                            style: GoogleFonts.notoSerif(
                              fontSize: 14,
                              color: AppColors.textCream.withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          itemCount: languages.length,
                          separatorBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: _buildGradientDivider(),
                          ),
                          itemBuilder: (context, index) {
                            final language = languages[index];
                            return _LanguageOption(
                              name: language.name,
                              nativeName: language.nativeName,
                              speakerCount: language.speakerCount,
                              status: language.status,
                              onTap: () {
                                ref
                                    .read(selectedLanguageProvider.notifier)
                                    .state = language;
                                context.go('/user-level');
                              },
                            );
                          },
                        ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gradient divider line with subtle fade at edges.
  static Widget _buildGradientDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.textCream.withValues(alpha: 0.0),
            AppColors.textCream.withValues(alpha: 0.25),
            AppColors.textCream.withValues(alpha: 0.25),
            AppColors.textCream.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

/// A single language option displayed as centered text.
class _LanguageOption extends StatelessWidget {
  final String name;
  final String? nativeName;
  final int speakerCount;
  final String status;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.name,
    this.nativeName,
    required this.speakerCount,
    required this.status,
    required this.onTap,
  });

  String _formatSpeakerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M speakers';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)},000 speakers';
    }
    return '$count speakers';
  }

  Color _statusColor() {
    switch (status) {
      case 'active':
        return AppColors.active;
      case 'vulnerable':
        return AppColors.vulnerable;
      case 'endangered':
        return AppColors.endangered;
      default:
        return AppColors.textCream;
    }
  }

  String _statusLabel() {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            // Language name
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                color: AppColors.textCream,
                letterSpacing: 1.5,
              ),
            ),

            // Native name
            if (nativeName != null && nativeName!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                nativeName!,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSerif(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textCream.withValues(alpha: 0.7),
                ),
              ),
            ],

            const SizedBox(height: 6),

            // Speaker count
            Text(
              _formatSpeakerCount(speakerCount),
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 13,
                color: AppColors.textCream.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 6),

            // Status badge as text
            Text(
              _statusLabel(),
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: _statusColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
