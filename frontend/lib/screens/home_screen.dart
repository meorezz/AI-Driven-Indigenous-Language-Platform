import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/region-select');
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.lightGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _showMenuDrawer(context),
                        child: const Icon(
                          Icons.menu,
                          color: AppColors.textLight,
                          size: 26,
                        ),
                      ),
                      Text(
                        'HORIZON',
                        style: GoogleFonts.notoSerif(
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textLight,
                          letterSpacing: 4.8,
                        ),
                      ),
                      const Icon(
                        Icons.account_circle_outlined,
                        color: AppColors.textLight,
                        size: 26,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Main heading
                Text(
                  'Cultural Heritage',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerif(
                    fontSize: 30,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SELECT A CATEGORY TO EXPLORE',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerif(
                    fontSize: 14,
                    color: AppColors.textLight.withValues(alpha: 0.80),
                    letterSpacing: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // Categories list
                Expanded(
                  child: categoriesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.textLight,
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.textLight.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load categories',
                              style: GoogleFonts.notoSerif(
                                fontSize: 16,
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => ref.invalidate(categoriesProvider),
                              child: Text(
                                'Tap to retry',
                                style: GoogleFonts.notoSerif(
                                  fontSize: 14,
                                  color: AppColors.textLight
                                      .withValues(alpha: 0.80),
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.textLight
                                      .withValues(alpha: 0.80),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (categories) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Column(
                            children: [
                              if (index > 0) _buildGradientDivider(),
                              _buildCategoryRow(category),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                // Bottom navigation bar
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.textLight.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavIcon(Icons.home, 0),
                            _buildNavIcon(Icons.bookmark_border, 1),
                            _buildNavIcon(Icons.menu_book_outlined, 2),
                            _buildNavIcon(Icons.settings_outlined, 3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(category) {
    return GestureDetector(
      onTap: () => context.push('/category/${category.id}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                category.name,
                style: GoogleFonts.notoSerif(
                  fontSize: 20,
                  color: AppColors.textLight,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Text(
              '\u203A',
              style: GoogleFonts.notoSerif(
                fontSize: 24,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.textLight.withValues(alpha: 0.0),
            AppColors.textLight.withValues(alpha: 0.30),
            AppColors.textLight.withValues(alpha: 0.30),
            AppColors.textLight.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      child: Icon(
        isActive && icon == Icons.bookmark_border
            ? Icons.bookmark
            : isActive && icon == Icons.menu_book_outlined
                ? Icons.menu_book
                : isActive && icon == Icons.settings_outlined
                    ? Icons.settings
                    : icon,
        color: AppColors.textLight
            .withValues(alpha: isActive ? 1.0 : 0.60),
        size: 26,
      ),
    );
  }

  void _showMenuDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textDark.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(
                    Icons.volunteer_activism,
                    color: AppColors.textDark,
                  ),
                  title: Text(
                    'Contribute',
                    style: GoogleFonts.notoSerif(
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/contribute');
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
