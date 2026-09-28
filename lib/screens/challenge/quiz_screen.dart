import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/quiz_option_card.dart';

/// The quiz game screen — shows questions one at a time with animated transitions.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quizProvider = context.watch<QuizProvider>();

    // Quiz finished
    if (!quizProvider.isQuizActive && quizProvider.questions.isNotEmpty) {
      return _QuizResultScreen(
        score: quizProvider.score,
        total: quizProvider.questions.length,
        highScore: quizProvider.highScore,
        onRestart: () {
          quizProvider.resetQuiz();
          Navigator.pop(context);
        },
      );
    }

    final question = quizProvider.currentQuestion;
    if (question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: CircularProgressIndicator(color: AppConstants.teal),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${quizProvider.currentQuestionIndex + 1}/${quizProvider.questions.length}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            _showQuitDialog(context, quizProvider);
          },
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: quizProvider.progress,
            backgroundColor: isDark
                ? AppConstants.slateLight.withValues(alpha: 0.3)
                : AppConstants.warmGrayMid,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppConstants.teal),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Score indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: AppConstants.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Score: ${quizProvider.score}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppConstants.amber,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Question
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingLg,
                    ),
                    child: Text(
                      question.questionText,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Options
                  ...List.generate(question.options.length, (index) {
                    return QuizOptionCard(
                      text: question.options[index],
                      index: index,
                      isSelected: quizProvider.selectedAnswer == index,
                      isCorrect: index == question.correctIndex,
                      isRevealed: quizProvider.isAnswered,
                      onTap: () => quizProvider.answerQuestion(index),
                    );
                  }),

                  // Explanation after answering
                  if (quizProvider.isAnswered) ...[
                    const SizedBox(height: 20),
                    _buildExplanation(context, question, quizProvider),
                  ],
                ],
              ),
            ),
          ),

          // Next button
          if (quizProvider.isAnswered)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => quizProvider.nextQuestion(),
                    child: Text(
                      quizProvider.isLastQuestion
                          ? 'See Results'
                          : 'Next Question',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExplanation(
    BuildContext context,
    QuizQuestion question,
    QuizProvider provider,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCorrect =
        provider.selectedAnswer == question.correctIndex;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
      ),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: (isCorrect ? AppConstants.successGreen : AppConstants.amber)
            .withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: (isCorrect ? AppConstants.successGreen : AppConstants.amber)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.celebration_rounded
                    : Icons.lightbulb_rounded,
                color:
                    isCorrect ? AppConstants.successGreen : AppConstants.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct!' : 'Not quite!',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isCorrect
                      ? AppConstants.successGreen
                      : AppConstants.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${question.idiom.idiom}" means: ${question.idiom.meaning}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showQuitDialog(BuildContext context, QuizProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to quit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              provider.resetQuiz();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.errorRed,
            ),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}

// ─── Results Screen ──────────────────────────────────────────────

class _QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int highScore;
  final VoidCallback onRestart;

  const _QuizResultScreen({
    required this.score,
    required this.total,
    required this.highScore,
    required this.onRestart,
  });

  String get _grade {
    final pct = score / total;
    if (pct >= 0.9) return '🏆 Master Detective';
    if (pct >= 0.7) return '🕵️ Senior Detective';
    if (pct >= 0.5) return '🔍 Junior Detective';
    if (pct >= 0.3) return '📚 Apprentice';
    return '🌱 Rookie';
  }

  Color get _gradeColor {
    final pct = score / total;
    if (pct >= 0.9) return AppConstants.amber;
    if (pct >= 0.7) return AppConstants.teal;
    if (pct >= 0.5) return AppConstants.intermediateBlue;
    if (pct >= 0.3) return AppConstants.advancedPurple;
    return AppConstants.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pct = (score / total * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Grade icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _gradeColor.withValues(alpha: 0.2),
                        _gradeColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _grade.split(' ')[0],
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  _grade.split(' ').skip(1).join(' '),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _gradeColor,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '$score out of $total correct ($pct%)',
                  style: theme.textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                if (score >= highScore && score > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.amber.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                      border: Border.all(
                        color: AppConstants.amber.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: AppConstants.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'New High Score!',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppConstants.amber,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRestart,
                    child: const Text('Back to Challenges'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
