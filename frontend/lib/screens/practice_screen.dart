import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/concept.dart';
import '../services/supabase_service.dart';
import '../services/audio_service.dart';

final _practiceConceptProvider = FutureProvider.family<Concept, String>((ref, conceptId) async {
  return SupabaseService.getConcept(conceptId);
});

enum RecordingState { idle, recording, processing, result }

class PracticeScreen extends ConsumerStatefulWidget {
  final String conceptId;

  const PracticeScreen({super.key, required this.conceptId});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen>
    with SingleTickerProviderStateMixin {
  RecordingState _state = RecordingState.idle;
  int? _score;
  String? _feedback;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final path = await AudioService.startRecording();
    if (path != null) {
      setState(() => _state = RecordingState.recording);
      _pulseController.repeat(reverse: true);
    }
  }

  Future<void> _stopRecording() async {
    _pulseController.stop();
    _pulseController.reset();
    setState(() => _state = RecordingState.processing);

    await AudioService.stopRecording();

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 1));

    final random = Random();
    final score = 60 + random.nextInt(36); // 60-95
    String feedback;
    if (score >= 90) {
      feedback = 'Excellent! Your pronunciation is very close to native!';
    } else if (score >= 80) {
      feedback = 'Great job! Just a few minor adjustments needed.';
    } else if (score >= 70) {
      feedback = 'Good attempt! Try listening to the audio again and focus on the vowel sounds.';
    } else {
      feedback = 'Keep practicing! Pay attention to the stressed syllables.';
    }

    if (mounted) {
      setState(() {
        _state = RecordingState.result;
        _score = score;
        _feedback = feedback;
      });
    }
  }

  void _tryAgain() {
    setState(() {
      _state = RecordingState.idle;
      _score = null;
      _feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conceptAsync = ref.watch(_practiceConceptProvider(widget.conceptId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Practice',
          style: GoogleFonts.notoSerif(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: AppColors.textLight,
            letterSpacing: 4.8,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: conceptAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.textCream),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.textCream.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load concept',
                      style: GoogleFonts.notoSerif(
                        fontSize: 16,
                        color: AppColors.textCream,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () =>
                          ref.invalidate(_practiceConceptProvider(widget.conceptId)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textCream,
                        side: const BorderSide(color: AppColors.textCream),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Retry', style: GoogleFonts.notoSerif()),
                    ),
                  ],
                ),
              ),
            ),
            data: (concept) => _buildPracticeContent(concept),
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeContent(Concept concept) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Word and translation
          Text(
            concept.word,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              fontSize: 32,
              color: AppColors.textCream,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            concept.translation,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              color: AppColors.textCream.withValues(alpha: 0.7),
            ),
          ),
          if (concept.audioUrl != null && concept.audioUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => AudioService.playUrl(concept.audioUrl!),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.volume_up,
                    color: AppColors.textCream.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Listen first',
                    style: GoogleFonts.notoSerif(
                      color: AppColors.textCream.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 48),
          // Microphone button
          _buildMicButton(),
          const SizedBox(height: 16),
          _buildStateLabel(),
          const SizedBox(height: 32),
          // Result section
          if (_state == RecordingState.result) _buildResult(),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    final isRecording = _state == RecordingState.recording;
    final isProcessing = _state == RecordingState.processing;

    return GestureDetector(
      onTap: () {
        if (_state == RecordingState.idle) {
          _startRecording();
        } else if (_state == RecordingState.recording) {
          _stopRecording();
        }
      },
      child: AnimatedBuilder(
        listenable: _pulseController,
        builder: (context, child) {
          final scale = isRecording ? 1.0 + (_pulseController.value * 0.1) : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isRecording
                    ? AppColors.error
                    : isProcessing
                        ? AppColors.textDarkMuted
                        : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isRecording
                      ? AppColors.error
                      : AppColors.textCream.withValues(alpha: 0.6),
                  width: 2,
                ),
                boxShadow: isRecording
                    ? [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: isProcessing
                  ? const Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(
                        color: AppColors.textCream,
                        strokeWidth: 3,
                      ),
                    )
                  : Icon(
                      Icons.mic,
                      size: 44,
                      color: isRecording
                          ? Colors.white
                          : AppColors.textCream.withValues(alpha: 0.9),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStateLabel() {
    String label;
    switch (_state) {
      case RecordingState.idle:
        label = 'Tap to record';
      case RecordingState.recording:
        label = 'Tap to stop';
      case RecordingState.processing:
        label = 'Analyzing...';
      case RecordingState.result:
        label = '';
    }

    return Text(
      label,
      style: GoogleFonts.notoSerif(
        fontSize: 14,
        color: AppColors.textCream.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildResult() {
    final score = _score ?? 0;
    Color scoreColor;
    if (score >= 85) {
      scoreColor = AppColors.success;
    } else if (score >= 70) {
      scoreColor = AppColors.warning;
    } else {
      scoreColor = AppColors.error;
    }

    return Column(
      children: [
        // Score
        Text(
          '$score%',
          style: GoogleFonts.notoSerif(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: scoreColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _feedback ?? '',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSerif(
            fontSize: 15,
            color: AppColors.textCream.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _tryAgain,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textCream,
                  side: BorderSide(
                    color: AppColors.textCream.withValues(alpha: 0.6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.notoSerif(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textCream.withValues(alpha: 0.2),
                  foregroundColor: AppColors.textCream,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Next Word',
                  style: GoogleFonts.notoSerif(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
