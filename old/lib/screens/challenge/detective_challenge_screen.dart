import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/quiz_option_card.dart';

/// Detective Challenge — a tougher quiz variant with 15 mixed-difficulty questions.
///
/// Shares the same quiz engine but has different UI theming (amber/gold).
class DetectiveChallengeScreen extends StatelessWidget {
  const DetectiveChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quizProvider = context.watch<QuizProvider>();

    // Challenge finished
    if (!quizProvider.isQuizActive && quizProvider.questions.isNotEmpty) {
      return _ChallengeResultScreen(
        score: quizProvider.score,
        total: quizProvider.questions.length,
        onDone: () {
          quizProvider.resetQuiz();
          Navigator.pop(context);
        },
      );
    }

    final question = quizProvider.currentQuestion;
    if (question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detective Challenge')),
        body: const Center(
          child: CircularProgressIndicator(color: AppConstants.amber),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: AppConstants.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Case ${quizProvider.currentQuestionIndex + 1}/${quizProvider.questions.length}',
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Abandon Case?'),
                content: const Text(
                  'Your detective challenge progress will be lost.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Continue'),
                  ),
                  TextButton(
                    onPressed: () {
                      quizProvider.resetQuiz();
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.errorRed,
                    ),
                    child: const Text('Abandon'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Progress bar (amber themed)
          LinearProgressIndicator(
            value: quizProvider.progress,
            backgroundColor: isDark
                ? AppConstants.slateLight.withValues(alpha: 0.3)
                : AppConstants.warmGrayMid,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppConstants.amber),
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
                  // Score
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_rounded,
                            size: 18, color: AppConstants.amber),
                        const SizedBox(width: 6),
                        Text(
                          'Cases Solved: ${quizProvider.score}',
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

                  if (quizProvider.isAnswered) ...[
                    const SizedBox(height: 20),
                    _buildCaseFile(context, question, quizProvider),
                  ],
                ],
              ),
            ),
          ),

          if (quizProvider.isAnswered)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => quizProvider.nextQuestion(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.amber,
                      foregroundColor: AppConstants.slateDarkest,
                    ),
                    child: Text(
                      quizProvider.isLastQuestion
                          ? 'Case Closed'
                          : 'Next Case',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaseFile(
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
        color: AppConstants.amber.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppConstants.amber.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.info_rounded,
                color: isCorrect
                    ? AppConstants.successGreen
                    : AppConstants.amber,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Case Solved! 🎉' : 'Case File 📂',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${question.idiom.idiom}"',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            question.idiom.meaning,
            style: theme.textTheme.bodyMedium,
          ),
          if (question.idiom.example.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Example: "${question.idiom.example}"',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Challenge Results ───────────────────────────────────────────

class _ChallengeResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onDone;

  const _ChallengeResultScreen({
    required this.score,
    required this.total,
    required this.onDone,
  });

  String get _badge {
    final pct = score / total;
    if (pct >= 0.9) return '🥇 Gold Badge';
    if (pct >= 0.7) return '🥈 Silver Badge';
    if (pct >= 0.5) return '🥉 Bronze Badge';
    return '🔍 Keep Investigating';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (score / total * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _badge.split(' ')[0],
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 16),
                Text(
                  'Challenge Complete!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _badge.split(' ').skip(1).join(' '),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppConstants.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$score / $total cases solved ($pct%)',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.amber,
                      foregroundColor: AppConstants.slateDarkest,
                    ),
                    child: const Text('Back to HQ'),
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
