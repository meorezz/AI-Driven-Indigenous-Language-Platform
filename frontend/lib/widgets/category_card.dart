import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final int conceptCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.conceptCount,
    required this.onTap,
  });

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'people':
        return Icons.people;
      case 'nutrition':
        return Icons.restaurant;
      case 'leaf':
        return Icons.eco;
      case 'cube':
        return Icons.inventory_2;
      case 'zap':
        return Icons.flash_on;
      case 'message-circle':
        return Icons.chat_bubble;
      default:
        return Icons.category;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getIcon(category.icon),
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$conceptCount words',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
