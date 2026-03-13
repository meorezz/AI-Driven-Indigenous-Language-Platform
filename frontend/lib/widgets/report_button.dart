import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class ReportButton extends StatelessWidget {
  final String conceptId;

  const ReportButton({
    super.key,
    required this.conceptId,
  });

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What seems wrong with this content?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _ReportOption(
              label: 'Wrong pronunciation',
              icon: Icons.record_voice_over,
              onTap: () => _submitReport(context, 'wrong_pronunciation'),
            ),
            _ReportOption(
              label: 'Wrong translation',
              icon: Icons.translate,
              onTap: () => _submitReport(context, 'wrong_translation'),
            ),
            _ReportOption(
              label: 'Wrong image',
              icon: Icons.image,
              onTap: () => _submitReport(context, 'wrong_image'),
            ),
            _ReportOption(
              label: 'Other',
              icon: Icons.more_horiz,
              onTap: () => _submitReport(context, 'other'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(BuildContext context, String reportType) async {
    Navigator.of(context).pop();
    try {
      await SupabaseService.submitReport(
        conceptId: conceptId,
        reportType: reportType,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. Thank you!'),
            backgroundColor: AppColors.primary,
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
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showReportDialog(context),
      icon: const Icon(Icons.flag_outlined),
      tooltip: 'Report issue',
    );
  }
}

class _ReportOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ReportOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
