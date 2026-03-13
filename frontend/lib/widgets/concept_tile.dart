import 'package:flutter/material.dart';
import '../models/concept.dart';
import '../theme/app_theme.dart';

class ConceptTile extends StatelessWidget {
  final Concept concept;
  final VoidCallback onTap;
  final VoidCallback? onPlayAudio;

  const ConceptTile({
    super.key,
    required this.concept,
    required this.onTap,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      concept.translation,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (concept.pronunciationGuide != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '/${concept.pronunciationGuide}/',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (concept.audioUrl != null && onPlayAudio != null)
                IconButton(
                  onPressed: onPlayAudio,
                  icon: const Icon(Icons.volume_up),
                  color: AppColors.primary,
                  iconSize: 28,
                ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
