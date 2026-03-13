import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/concept.dart';
import '../providers/app_providers.dart';
import '../services/audio_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class ContributeScreen extends ConsumerStatefulWidget {
  const ContributeScreen({super.key});

  @override
  ConsumerState<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends ConsumerState<ContributeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Contribute',
          style: GoogleFonts.notoSerif(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: AppColors.textLight,
            letterSpacing: 4.8,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textCream,
          indicatorWeight: 2,
          labelColor: AppColors.textCream,
          unselectedLabelColor: AppColors.textCream.withValues(alpha: 0.5),
          labelStyle: GoogleFonts.notoSerif(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.notoSerif(fontSize: 13),
          tabs: const [
            Tab(text: 'Add Pronunciation'),
            Tab(text: 'Suggest a Word'),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _AddPronunciationTab(),
              _SuggestWordTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Shared styling helpers
// ============================================================

InputDecoration _themedInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.notoSerif(
      color: AppColors.textCream.withValues(alpha: 0.7),
      fontSize: 14,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppColors.textCream.withValues(alpha: 0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppColors.textCream.withValues(alpha: 0.6),
        width: 1.5,
      ),
    ),
    filled: false,
  );
}

DropdownButtonFormField<T> _themedDropdown<T>({
  required T? value,
  required String label,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  return DropdownButtonFormField<T>(
    initialValue: value,
    decoration: _themedInputDecoration(label),
    dropdownColor: AppColors.gradientEnd,
    style: GoogleFonts.notoSerif(
      color: AppColors.textCream,
      fontSize: 15,
    ),
    iconEnabledColor: AppColors.textCream.withValues(alpha: 0.7),
    items: items,
    onChanged: onChanged,
  );
}

// ============================================================
// Add Pronunciation Tab
// ============================================================
class _AddPronunciationTab extends ConsumerStatefulWidget {
  const _AddPronunciationTab();

  @override
  ConsumerState<_AddPronunciationTab> createState() => _AddPronunciationTabState();
}

class _AddPronunciationTabState extends ConsumerState<_AddPronunciationTab> {
  String? _selectedCategoryId;
  Concept? _selectedConcept;
  bool _isRecording = false;
  String? _recordingPath;
  bool _isSubmitting = false;
  List<Concept> _concepts = [];
  bool _loadingConcepts = false;

  Future<void> _loadConcepts(String categoryId) async {
    final language = ref.read(selectedLanguageProvider);
    if (language == null) return;

    setState(() => _loadingConcepts = true);
    try {
      final concepts = await SupabaseService.getConcepts(
        languageId: language.id,
        categoryId: categoryId,
      );
      setState(() {
        _concepts = concepts;
        _selectedConcept = null;
        _loadingConcepts = false;
      });
    } catch (e) {
      setState(() => _loadingConcepts = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await AudioService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });
    } else {
      final path = await AudioService.startRecording();
      if (path != null) {
        setState(() {
          _isRecording = true;
          _recordingPath = null;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedConcept == null || _recordingPath == null) return;
    final language = ref.read(selectedLanguageProvider);
    if (language == null) return;

    setState(() => _isSubmitting = true);
    try {
      await SupabaseService.submitContribution(
        languageId: language.id,
        conceptId: _selectedConcept!.id,
        contributorType: ref.read(userLevelProvider),
        audioUrl: _recordingPath,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pronunciation submitted! Thank you.'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _selectedConcept = null;
          _recordingPath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record a pronunciation',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textCream,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a word and record your pronunciation.',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              color: AppColors.textCream.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          // Category dropdown
          categoriesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.textCream),
            ),
            error: (_, __) => Text(
              'Failed to load categories',
              style: GoogleFonts.notoSerif(color: AppColors.error),
            ),
            data: (categories) => _themedDropdown<String>(
              value: _selectedCategoryId,
              label: 'Category',
              items: categories.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategoryId = value);
                if (value != null) _loadConcepts(value);
              },
            ),
          ),
          const SizedBox(height: 16),
          // Word dropdown
          if (_loadingConcepts)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.textCream),
              ),
            )
          else if (_concepts.isNotEmpty)
            _themedDropdown<Concept>(
              value: _selectedConcept,
              label: 'Word',
              items: _concepts.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text('${c.word} - ${c.translation}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedConcept = value),
            ),
          const SizedBox(height: 32),
          // Record button
          if (_selectedConcept != null) ...[
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? AppColors.error
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isRecording
                              ? AppColors.error
                              : AppColors.textCream.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 36,
                        color: _isRecording
                            ? Colors.white
                            : AppColors.textCream.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRecording
                        ? 'Recording... Tap to stop'
                        : _recordingPath != null
                            ? 'Recording saved'
                            : 'Tap to record',
                    style: GoogleFonts.notoSerif(
                      fontSize: 14,
                      color: _isRecording
                          ? AppColors.error
                          : AppColors.textCream.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            if (_recordingPath != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textCream.withValues(alpha: 0.2),
                    foregroundColor: AppColors.textCream,
                    disabledBackgroundColor:
                        AppColors.textCream.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textCream,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: GoogleFonts.notoSerif(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Suggest Word Tab
// ============================================================
class _SuggestWordTab extends ConsumerStatefulWidget {
  const _SuggestWordTab();

  @override
  ConsumerState<_SuggestWordTab> createState() => _SuggestWordTabState();
}

class _SuggestWordTabState extends ConsumerState<_SuggestWordTab> {
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  String? _selectedCategoryId;
  bool _isRecording = false;
  String? _recordingPath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await AudioService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });
    } else {
      final path = await AudioService.startRecording();
      if (path != null) {
        setState(() {
          _isRecording = true;
          _recordingPath = null;
        });
      }
    }
  }

  Future<void> _submit() async {
    final word = _wordController.text.trim();
    final translation = _translationController.text.trim();
    if (word.isEmpty || translation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both word and translation.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    final language = ref.read(selectedLanguageProvider);
    if (language == null) return;

    setState(() => _isSubmitting = true);
    try {
      await SupabaseService.submitContribution(
        languageId: language.id,
        contributorType: ref.read(userLevelProvider),
        word: word,
        translation: translation,
        audioUrl: _recordingPath,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Word suggestion submitted! Thank you.'),
            backgroundColor: AppColors.success,
          ),
        );
        _wordController.clear();
        _translationController.clear();
        setState(() {
          _recordingPath = null;
          _selectedCategoryId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggest a new word',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textCream,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help grow the dictionary by suggesting words.',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              color: AppColors.textCream.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          // Category dropdown
          categoriesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.textCream),
            ),
            error: (_, __) => Text(
              'Failed to load categories',
              style: GoogleFonts.notoSerif(color: AppColors.error),
            ),
            data: (categories) => _themedDropdown<String>(
              value: _selectedCategoryId,
              label: 'Category',
              items: categories.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategoryId = value),
            ),
          ),
          const SizedBox(height: 16),
          // Word input
          TextField(
            controller: _wordController,
            style: GoogleFonts.notoSerif(
              color: AppColors.textCream,
              fontSize: 15,
            ),
            cursorColor: AppColors.textCream,
            decoration: _themedInputDecoration('Word (in indigenous language)'),
          ),
          const SizedBox(height: 16),
          // Translation input
          TextField(
            controller: _translationController,
            style: GoogleFonts.notoSerif(
              color: AppColors.textCream,
              fontSize: 15,
            ),
            cursorColor: AppColors.textCream,
            decoration: _themedInputDecoration('Translation (in English)'),
          ),
          const SizedBox(height: 24),
          // Optional audio recording
          Text(
            'Optional: Record pronunciation',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textCream.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? AppColors.error
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRecording
                            ? AppColors.error
                            : AppColors.textCream.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 28,
                      color: _isRecording
                          ? Colors.white
                          : AppColors.textCream.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRecording
                      ? 'Recording...'
                      : _recordingPath != null
                          ? 'Recording saved'
                          : 'Tap to record',
                  style: GoogleFonts.notoSerif(
                    fontSize: 13,
                    color: _isRecording
                        ? AppColors.error
                        : AppColors.textCream.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textCream.withValues(alpha: 0.2),
                foregroundColor: AppColors.textCream,
                disabledBackgroundColor:
                    AppColors.textCream.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.textCream,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit',
                      style: GoogleFonts.notoSerif(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
