import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/constants.dart';
import 'quiz_screen.dart';
import 'detective_challenge_screen.dart';

/// Challenge hub — choose Quiz Mode or Detective Challenge.
class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quizProvider = context.watch<QuizProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Challenge')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Stats Overview ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppConstants.tealDark.withValues(alpha: 0.3),
                          AppConstants.slateMid,
                        ]
                      : [
                          AppConstants.teal.withValues(alpha: 0.08),
                          Colors.white,
                        ],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                border: Border.all(
                  color: AppConstants.teal.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Detective Record',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        icon: Icons.emoji_events_rounded,
                        value: '${quizProvider.highScore}',
                        label: 'High Score',
                        color: AppConstants.amber,
                        isDark: isDark,
                      ),
                      _StatItem(
                        icon: Icons.quiz_rounded,
                        value: '${quizProvider.totalQuizzes}',
                        label: 'Quizzes',
                        color: AppConstants.teal,
                        isDark: isDark,
                      ),
                      _StatItem(
                        icon: Icons.local_fire_department_rounded,
                        value: '${quizProvider.streak}',
                        label: 'Streak',
                        color: AppConstants.errorRed,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Quiz Mode ──────────────────────────────────────
            _ChallengeCard(
              title: 'Quiz Mode',
              subtitle:
                  'Test your idiom knowledge with ${AppConstants.quizQuestionCount} randomized questions.',
              icon: Icons.quiz_rounded,
              color: AppConstants.teal,
              gradient: [
                AppConstants.tealDark,
                AppConstants.teal,
              ],
              features: const [
                'Multiple choice questions',
                'Choose your difficulty',
                'Track your high score',
              ],
              buttonLabel: 'Start Quiz',
              isDark: isDark,
              onTap: () => _showDifficultyPicker(
                context,
                isChallenge: false,
              ),
            ),

            const SizedBox(height: 16),

            // ─── Detective Challenge ────────────────────────────
            _ChallengeCard(
              title: 'Detective Challenge',
              subtitle:
                  'The ultimate test — ${AppConstants.detectiveChallengeCount} tough questions, mixed difficulty.',
              icon: Icons.search_rounded,
              color: AppConstants.amber,
              gradient: [
                AppConstants.amberDark,
                AppConstants.amber,
              ],
              features: const [
                'All difficulty levels mixed',
                'Earn your detective badge',
                'Beat your best score',
              ],
              buttonLabel: 'Accept Challenge',
              isDark: isDark,
              onTap: () {
                context.read<QuizProvider>().startDetectiveChallenge().then((_) {
                  if (context.read<QuizProvider>().isQuizActive) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DetectiveChallengeScreen(),
                      ),
                    );
                  }
                });
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showDifficultyPicker(BuildContext context,
      {required bool isChallenge}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppConstants.slateMid : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppConstants.slateLight
                    : AppConstants.warmGrayMid,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose Difficulty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            // All difficulties option
            _DifficultyOption(
              name: 'All Levels',
              subtitle: 'Mix of all difficulties',
              color: AppConstants.teal,
              icon: Icons.shuffle_rounded,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                _startQuiz(context, 'all');
              },
            ),
            ...AppConstants.difficulties.map((diff) {
              return _DifficultyOption(
                name: diff['name'] as String,
                subtitle: _getDifficultySubtitle(diff['name'] as String),
                color: diff['color'] as Color,
                icon: diff['icon'] as IconData,
                isDark: isDark,
                onTap: () {
                  Navigator.pop(ctx);
                  _startQuiz(
                    context,
                    (diff['name'] as String).toLowerCase(),
                  );
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context, String difficulty) {
    context.read<QuizProvider>().startQuiz(difficulty: difficulty).then((_) {
      if (context.read<QuizProvider>().isQuizActive) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const QuizScreen(),
          ),
        );
      }
    });
  }

  String _getDifficultySubtitle(String name) {
    switch (name) {
      case 'Beginner':
        return 'Common, everyday idioms';
      case 'Intermediate':
        return 'Less common expressions';
      case 'Advanced':
        return 'Rare and challenging idioms';
      default:
        return '';
    }
  }
}

// ─── Supporting Widgets ──────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final List<String> features;
  final String buttonLabel;
  final bool isDark;
  final VoidCallback onTap;

  const _ChallengeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.features,
    required this.buttonLabel,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.slateMid : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(f, style: theme.textTheme.bodyMedium),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final String name;
  final String subtitle;
  final Color color;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _DifficultyOption({
    required this.name,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
