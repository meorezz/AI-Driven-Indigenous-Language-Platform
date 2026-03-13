import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';


class CategoryScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryScreen({super.key, required this.categoryId});

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
              onTap: () => Navigator.of(ctx).pop(),
            ),
            _ReportOption(
              label: 'Wrong translation',
              onTap: () => Navigator.of(ctx).pop(),
            ),
            _ReportOption(
              label: 'Wrong image',
              onTap: () => Navigator.of(ctx).pop(),
            ),
            _ReportOption(
              label: 'Other',
              onTap: () => Navigator.of(ctx).pop(),
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

  Widget _buildGradientDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        height: 0.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.textCream.withValues(alpha: 0.0),
              AppColors.textCream.withValues(alpha: 0.3),
              AppColors.textCream.withValues(alpha: 0.3),
              AppColors.textCream.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptsAsync = ref.watch(conceptsProvider(categoryId));
    final categoriesAsync = ref.watch(categoriesProvider);

    final categoryName = categoriesAsync.whenOrNull(
      data: (categories) {
        try {
          return categories.firstWhere((c) => c.id == categoryId).name;
        } catch (_) {
          return null;
        }
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => context.pop(),
        ),
        title: Text(
          categoryName ?? 'Category',
          style: GoogleFonts.notoSerif(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: AppColors.textLight,
            letterSpacing: 4.8,
          ),
        ),
        centerTitle: true,
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
          child: conceptsAsync.when(
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
                      'Failed to load words',
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
                      onPressed: () => ref.invalidate(conceptsProvider(categoryId)),
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
            data: (concepts) {
              if (concepts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 48,
                        color: AppColors.textCream.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No words yet in this category.',
                        style: GoogleFonts.notoSerif(
                          fontSize: 15,
                          color: AppColors.textCream.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                itemCount: concepts.length * 2 - 1,
                itemBuilder: (context, index) {
                  // Even indices are items, odd indices are dividers
                  if (index.isOdd) {
                    return _buildGradientDivider();
                  }
                  final conceptIndex = index ~/ 2;
                  final concept = concepts[conceptIndex];
                  return GestureDetector(
                    onTap: () => context.push('/concept/${concept.id}'),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            concept.word,
                            style: GoogleFonts.notoSerif(
                              fontSize: 22,
                              color: AppColors.textCream,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            concept.translation,
                            style: GoogleFonts.notoSerif(
                              fontSize: 15,
                              color: AppColors.textCream.withValues(alpha: 0.7),
                            ),
                          ),
                          if (concept.pronunciationGuide != null &&
                              concept.pronunciationGuide!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              concept.pronunciationGuide!,
                              style: GoogleFonts.notoSerif(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textCream.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
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
