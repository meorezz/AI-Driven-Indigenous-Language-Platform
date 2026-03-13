import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class RegionSelectScreen extends ConsumerWidget {
  const RegionSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionsAsync = ref.watch(regionsProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: regionsAsync.when(
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
                      'Failed to load regions',
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
                      onPressed: () => ref.invalidate(regionsProvider),
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
            data: (regions) => Column(
              children: [
                const SizedBox(height: 40),
                // Header
                Text(
                  'Choose Your Region',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerif(
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textCream,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Malaysia map placeholder
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _MalaysiaMapPlaceholder(),
                  ),
                ),

                const SizedBox(height: 24),

                // Region options
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < regions.length; i++) ...[
                          if (i > 0) ...[
                            const SizedBox(height: 16),
                            _buildDiamondDivider(),
                            const SizedBox(height: 16),
                          ],
                          _RegionOption(
                            name: regions[i].name,
                            description: regions[i].description ??
                                'Explore the indigenous languages of ${regions[i].name}.',
                            onTap: () {
                              ref.read(selectedRegionProvider.notifier).state =
                                  regions[i];
                              context.go('/language-select');
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Decorative divider: horizontal line + diamond + horizontal line.
  static Widget _buildDiamondDivider() {
    final color = AppColors.textCream.withValues(alpha: 0.3);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: color)),
        const SizedBox(width: 12),
        Transform.rotate(
          angle: 0.7854,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: color)),
      ],
    );
  }
}

/// Tappable region option displayed as centered elegant text.
class _RegionOption extends StatelessWidget {
  final String name;
  final String description;
  final VoidCallback onTap;

  const _RegionOption({
    required this.name,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                color: AppColors.textCream,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSerif(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textCream.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder for a Malaysia map silhouette built from Flutter shapes.
class _MalaysiaMapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 160,
      child: CustomPaint(
        painter: _MapOutlinePainter(),
      ),
    );
  }
}

/// Draws a simplified outline resembling Borneo (Sabah & Sarawak).
class _MapOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textCream.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = AppColors.textCream.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    // Simplified Borneo island outline
    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.3);
    path.lineTo(size.width * 0.25, size.height * 0.15);
    path.lineTo(size.width * 0.45, size.height * 0.1);
    path.lineTo(size.width * 0.6, size.height * 0.05);
    path.lineTo(size.width * 0.75, size.height * 0.15);
    path.lineTo(size.width * 0.85, size.height * 0.3);
    path.lineTo(size.width * 0.9, size.height * 0.5);
    path.lineTo(size.width * 0.85, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.85);
    path.lineTo(size.width * 0.5, size.height * 0.9);
    path.lineTo(size.width * 0.3, size.height * 0.85);
    path.lineTo(size.width * 0.15, size.height * 0.7);
    path.lineTo(size.width * 0.1, size.height * 0.5);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Divider line between Sabah (top) and Sarawak (bottom)
    final dividerPaint = Paint()
      ..color = AppColors.textCream.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final divider = Path();
    divider.moveTo(size.width * 0.15, size.height * 0.5);
    divider.quadraticBezierTo(
      size.width * 0.5, size.height * 0.45,
      size.width * 0.85, size.height * 0.5,
    );
    canvas.drawPath(divider, dividerPaint);

    // Labels
    final textStyle = TextStyle(
      color: AppColors.textCream.withValues(alpha: 0.35),
      fontSize: 11,
      letterSpacing: 2,
    );

    final sabahPainter = TextPainter(
      text: TextSpan(text: 'SABAH', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    sabahPainter.paint(
      canvas,
      Offset(
        (size.width - sabahPainter.width) / 2,
        size.height * 0.28,
      ),
    );

    final sarawakPainter = TextPainter(
      text: TextSpan(text: 'SARAWAK', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    sarawakPainter.paint(
      canvas,
      Offset(
        (size.width - sarawakPainter.width) / 2,
        size.height * 0.58,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
