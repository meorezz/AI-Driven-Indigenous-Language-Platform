import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/region-select');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: () => context.go('/region-select'),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Stack(
            children: [
              // Corner brackets with diamonds at 4 corners
              ..._buildCornerDecorations(size),

              // Vertical edge dividers with diamonds (left and right)
              _buildEdgeDivider(left: 30, size: size),
              _buildEdgeDivider(right: 30, size: size),

              // Center content
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Three nested rotated rectangles behind text
                    _buildRotatedRect(60, 120, 0.06),
                    _buildRotatedRect(50, 100, 0.04),
                    _buildRotatedRect(40, 80, 0.03),

                    // Diamond row above text
                    Positioned(
                      top: size.height / 2 - 80,
                      child: _buildDiamondRow(),
                    ),

                    // HORIZON text
                    Text(
                      'HORIZON',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textCream,
                        letterSpacing: 12,
                      ),
                    ),

                    // Diamond row below text
                    Positioned(
                      top: size.height / 2 + 50,
                      child: _buildDiamondRow(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds corner L-shapes with a diamond at each of the 4 screen corners.
  List<Widget> _buildCornerDecorations(Size size) {
    const double inset = 20;
    const double armLength = 40;
    const double thickness = 1.5;
    final color = AppColors.textCream.withValues(alpha: 0.4);

    Widget corner({
      required double top,
      required double left,
      required double right,
      required double bottom,
      required bool flipH,
      required bool flipV,
    }) {
      // We position at the corner and draw two arms + diamond
      return Positioned(
        top: top != -1 ? top : null,
        bottom: bottom != -1 ? bottom : null,
        left: left != -1 ? left : null,
        right: right != -1 ? right : null,
        child: SizedBox(
          width: armLength + 12,
          height: armLength + 12,
          child: Stack(
            children: [
              // Horizontal arm
              Positioned(
                top: flipV ? null : 0,
                bottom: flipV ? 0 : null,
                left: flipH ? null : 0,
                right: flipH ? 0 : null,
                child: Container(
                  width: armLength,
                  height: thickness,
                  color: color,
                ),
              ),
              // Vertical arm
              Positioned(
                top: flipV ? null : 0,
                bottom: flipV ? 0 : null,
                left: flipH ? null : 0,
                right: flipH ? 0 : null,
                child: Container(
                  width: thickness,
                  height: armLength,
                  color: color,
                ),
              ),
              // Diamond at the corner point
              Positioned(
                top: flipV ? null : -3,
                bottom: flipV ? -3 : null,
                left: flipH ? null : -3,
                right: flipH ? -3 : null,
                child: _buildDiamond(7, color),
              ),
            ],
          ),
        ),
      );
    }

    return [
      corner(top: inset, left: inset, right: -1, bottom: -1, flipH: false, flipV: false),
      corner(top: inset, left: -1, right: inset, bottom: -1, flipH: true, flipV: false),
      corner(top: -1, left: inset, right: -1, bottom: inset, flipH: false, flipV: true),
      corner(top: -1, left: -1, right: inset, bottom: inset, flipH: true, flipV: true),
    ];
  }

  /// Builds a vertical divider line with a diamond on the left or right edge.
  Widget _buildEdgeDivider({double? left, double? right, required Size size}) {
    final color = AppColors.textCream.withValues(alpha: 0.2);
    final lineHeight = size.height * 0.25;

    return Positioned(
      left: left,
      right: right,
      top: (size.height - lineHeight) / 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDiamond(6, color),
          Container(width: 1, height: lineHeight, color: color),
          _buildDiamond(6, color),
        ],
      ),
    );
  }

  /// Builds a row of three diamonds connected by gradient lines.
  Widget _buildDiamondRow() {
    final color = AppColors.textCream.withValues(alpha: 0.35);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 40, height: 1, color: color),
        _buildDiamond(5, color),
        Container(width: 20, height: 1, color: color),
        _buildDiamond(7, color),
        Container(width: 20, height: 1, color: color),
        _buildDiamond(5, color),
        Container(width: 40, height: 1, color: color),
      ],
    );
  }

  /// Builds a single rotated diamond shape.
  Widget _buildDiamond(double size, Color color) {
    return Transform.rotate(
      angle: 0.7854, // 45 degrees in radians
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
        ),
      ),
    );
  }

  /// Builds a nested rotated rectangle behind the title text.
  Widget _buildRotatedRect(double width, double height, double rotationAngle) {
    return Transform.rotate(
      angle: rotationAngle,
      child: Container(
        width: height,
        height: width,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textCream.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
    );
  }
}
