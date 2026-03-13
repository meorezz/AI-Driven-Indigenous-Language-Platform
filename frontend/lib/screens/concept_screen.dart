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
        title: Text(
          'Report an Issue',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
            child: const Text('Cancel'),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptAsync = ref.watch(_conceptProvider(conceptId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Report',
            onPressed: () => _showReportDialog(context),
          ),
        ],
      ),
      body: conceptAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load concept',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(_conceptProvider(conceptId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (concept) => SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Word display
              Text(
                concept.word,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              // Translation
              Text(
                concept.translation,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              // Pronunciation guide
              if (concept.pronunciationGuide != null &&
                  concept.pronunciationGuide!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  concept.pronunciationGuide!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppColors.accent,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              // Play audio button
              if (concept.audioUrl != null && concept.audioUrl!.isNotEmpty) ...[
                GestureDetector(
                  onTap: () => AudioService.playUrl(concept.audioUrl!),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to listen',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
              ],
              // Practice Speaking button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/practice/$conceptId'),
                  icon: const Icon(Icons.mic),
                  label: const Text('Practice Speaking'),
                ),
              ),
            ],
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
      title: Text(label, style: GoogleFonts.poppins(fontSize: 15)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
