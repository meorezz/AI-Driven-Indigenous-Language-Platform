import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class _QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

const _sampleQuestions = [
  _QuizQuestion(
    question: "What does 'Kotobian' mean?",
    options: ['Thank you', 'Hello / Congratulations', 'Goodbye', 'How are you'],
    correctIndex: 1,
  ),
  _QuizQuestion(
    question: "What does 'Aramaiti' mean?",
    options: ['Water', 'Food', 'Thank you', 'Friend'],
    correctIndex: 2,
  ),
  _QuizQuestion(
    question: "What does 'Wagu' mean?",
    options: ['Sun', 'Moon', 'Beautiful', 'River'],
    correctIndex: 2,
  ),
];

class QuickCheckScreen extends ConsumerStatefulWidget {
  const QuickCheckScreen({super.key});

  @override
  ConsumerState<QuickCheckScreen> createState() => _QuickCheckScreenState();
}

class _QuickCheckScreenState extends ConsumerState<QuickCheckScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _correctAnswers = 0;
  final List<int?> _selectedAnswers = List.filled(_sampleQuestions.length, null);
  bool _showResults = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectAnswer(int questionIndex, int optionIndex) {
    if (_selectedAnswers[questionIndex] != null) return;

    setState(() {
      _selectedAnswers[questionIndex] = optionIndex;
      if (optionIndex == _sampleQuestions[questionIndex].correctIndex) {
        _correctAnswers++;
      }
    });

    // Auto-advance after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_currentPage < _sampleQuestions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() => _showResults = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return _buildResultsScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quick Check')),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: List.generate(_sampleQuestions.length, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemCount: _sampleQuestions.length,
              itemBuilder: (context, index) {
                final question = _sampleQuestions[index];
                return _buildQuestionPage(question, index);
              },
            ),
          ),
          // Skip button
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextButton(
              onPressed: () => context.go('/home'),
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(_QuizQuestion question, int questionIndex) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Question ${questionIndex + 1} of ${_sampleQuestions.length}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          ...List.generate(question.options.length, (optionIndex) {
            final isSelected = _selectedAnswers[questionIndex] == optionIndex;
            final isCorrect = optionIndex == question.correctIndex;
            final hasAnswered = _selectedAnswers[questionIndex] != null;

            Color borderColor = Colors.transparent;
            Color bgColor = AppColors.surface;
            if (hasAnswered) {
              if (isSelected && isCorrect) {
                borderColor = AppColors.success;
                bgColor = AppColors.success.withValues(alpha: 0.1);
              } else if (isSelected && !isCorrect) {
                borderColor = AppColors.error;
                bgColor = AppColors.error.withValues(alpha: 0.1);
              } else if (isCorrect) {
                borderColor = AppColors.success;
                bgColor = AppColors.success.withValues(alpha: 0.05);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: hasAnswered ? null : () => _selectAnswer(questionIndex, optionIndex),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                        width: borderColor == Colors.transparent ? 0 : 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.options[optionIndex],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final total = _sampleQuestions.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Check')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _correctAnswers >= 2 ? Icons.emoji_events : Icons.school,
                size: 64,
                color: AppColors.accent,
              ),
              const SizedBox(height: 24),
              Text(
                'You got $_correctAnswers out of $total!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _correctAnswers >= 2
                    ? 'Great job! You have some knowledge of this language.'
                    : 'No worries! We\'ll start from the basics.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
