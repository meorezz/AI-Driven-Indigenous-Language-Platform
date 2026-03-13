import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PronunciationFeedback extends StatelessWidget {
  final int score;
  final String feedback;

  const PronunciationFeedback({
    super.key,
    required this.score,
    required this.feedback,
  });

  Color _getScoreColor() {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _getScoreLabel() {
    if (score >= 80) return 'Great!';
    if (score >= 60) return 'Good effort!';
    return 'Keep practicing!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getScoreColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getScoreColor().withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            _getScoreLabel(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getScoreColor(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor()),
                  ),
                ),
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            feedback,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
