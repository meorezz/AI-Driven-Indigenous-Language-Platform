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
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: languagesAsync.when(
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
                  'Failed to load languages',
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
                  onPressed: () => ref.invalidate(languagesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (languages) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedRegion != null) ...[
                Text(
                  'Languages of ${selectedRegion.name}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a language to begin learning.',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
              ],
              Expanded(
                child: languages.isEmpty
                    ? Center(
                        child: Text(
                          'No languages found for this region.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: languages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final language = languages[index];
                          return _LanguageCard(
                            name: language.name,
                            nativeName: language.nativeName,
                            speakerCount: language.speakerCount,
                            status: language.status,
                            onTap: () {
                              ref.read(selectedLanguageProvider.notifier).state = language;
                              context.go('/user-level');
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String name;
  final String? nativeName;
  final int speakerCount;
  final String status;
  final VoidCallback onTap;

  const _LanguageCard({
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
        return AppColors.textSecondary;
    }
  }

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (nativeName != null && nativeName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        nativeName!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _formatSpeakerCount(speakerCount),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
