import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../services/audio_service.dart';

class CategoryScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryScreen({super.key, required this.categoryId});

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
      appBar: AppBar(
        title: Text(categoryName ?? 'Category'),
      ),
      body: conceptsAsync.when(
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
                  'Failed to load concepts',
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
                  onPressed: () => ref.invalidate(conceptsProvider(categoryId)),
                  child: const Text('Retry'),
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
                  Icon(Icons.inbox, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No words yet in this category.',
                    style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: concepts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final concept = concepts[index];
              return Card(
                child: InkWell(
                  onTap: () => context.push('/concept/${concept.id}'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                concept.word,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                concept.translation,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (concept.pronunciationGuide != null &&
                                  concept.pronunciationGuide!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  concept.pronunciationGuide!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (concept.audioUrl != null && concept.audioUrl!.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill),
                            iconSize: 36,
                            color: AppColors.primary,
                            onPressed: () => AudioService.playUrl(concept.audioUrl!),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
