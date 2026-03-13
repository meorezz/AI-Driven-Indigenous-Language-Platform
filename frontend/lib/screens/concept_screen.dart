import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/concept.dart';
import '../services/supabase_service.dart';
import '../services/audio_service.dart';

final _conceptProvider = FutureProvider.family<Concept, String>((ref, conceptId) async {
  return SupabaseService.getConcept(conceptId);
});

class ConceptScreen extends ConsumerWidget {
  final String conceptId;

  const ConceptScreen({super.key, required this.conceptId});

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Report an Issue',
          style: GoogleFonts.notoSerif(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ReportOption(
              label: 'Wrong pronunciation',
              onTap: () {
                Navigator.of(ctx).pop();
                _submitReport(context, 'wrong_pronunciation');
              },
            ),
            _ReportOption(
              label: 'Wrong translation',
              onTap: () {
                Navigator.of(ctx).pop();
                _submitReport(context, 'wrong_translation');
              },
            ),
            _ReportOption(
              label: 'Wrong image',
              onTap: () {
                Navigator.of(ctx).pop();
                _submitReport(context, 'wrong_image');
              },
            ),
            _ReportOption(
              label: 'Other',
              onTap: () {
                Navigator.of(ctx).pop();
                _submitReport(context, 'other');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.notoSerif(color: AppColors.gradientEnd),
            ),
          ),
        ],
      ),
    );
  }

  void _submitReport(BuildContext context, String reportType) async {
    try {
      await SupabaseService.submitReport(
        conceptId: conceptId,
        reportType: reportType,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. Thank you!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildDiamondSeparator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 0.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.textCream.withValues(alpha: 0.0),
                AppColors.textCream.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.textCream.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 0.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.textCream.withValues(alpha: 0.3),
                AppColors.textCream.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptAsync = ref.watch(_conceptProvider(conceptId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: AppColors.textLight),
            tooltip: 'Report',
            onPressed: () => _showReportDialog(context),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: conceptAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.textCream),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.textCream.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load concept',
                      style: GoogleFonts.notoSerif(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textCream,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerif(
                        fontSize: 14,
                        color: AppColors.textCream.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(_conceptProvider(conceptId)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textCream,
                        side: const BorderSide(color: AppColors.textCream),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Retry', style: GoogleFonts.notoSerif()),
                    ),
                  ],
                ),
              ),
            ),
            data: (concept) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Large word display
                    Text(
                      concept.word,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerif(
                        fontSize: 44,
                        color: AppColors.textCream,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Translation
                    Text(
                      concept.translation,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerif(
                        fontSize: 20,
                        color: AppColors.textCream.withValues(alpha: 0.7),
                      ),
                    ),
                    // Pronunciation guide
                    if (concept.pronunciationGuide != null &&
                        concept.pronunciationGuide!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        concept.pronunciationGuide!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSerif(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textCream.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    // Diamond separator
                    _buildDiamondSeparator(),
                    const SizedBox(height: 32),
                    // Play audio button
                    if (concept.audioUrl != null && concept.audioUrl!.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () => AudioService.playUrl(concept.audioUrl!),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.textCream.withValues(alpha: 0.6),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.volume_up,
                            size: 36,
                            color: AppColors.textCream.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to listen',
                        style: GoogleFonts.notoSerif(
                          fontSize: 14,
                          color: AppColors.textCream.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Another separator
                      _buildDiamondSeparator(),
                      const SizedBox(height: 32),
                    ],
                    // Practice Speaking button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/practice/$conceptId'),
                        icon: Icon(
                          Icons.mic,
                          color: AppColors.textCream.withValues(alpha: 0.9),
                        ),
                        label: Text(
                          'Practice Speaking',
                          style: GoogleFonts.notoSerif(
                            fontSize: 16,
                            color: AppColors.textCream,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textCream,
                          side: BorderSide(
                            color: AppColors.textCream.withValues(alpha: 0.6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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

class _ReportOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ReportOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.notoSerif(fontSize: 15, color: AppColors.textDark),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
