import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/idiom_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/difficulty_badge.dart';

/// Full detail screen for a single idiom.
///
/// Displays: idiom name, meaning, explanation, example sentence,
/// usage (formal/informal), difficulty, origin, related expressions,
/// with favorite toggle and share actions.
class IdiomDetailScreen extends StatefulWidget {
  final int idiomId;

  const IdiomDetailScreen({super.key, required this.idiomId});

  @override
  State<IdiomDetailScreen> createState() => _IdiomDetailScreenState();
}

class _IdiomDetailScreenState extends State<IdiomDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppConstants.animSlow,
    );
    _animController.forward();

    // Load the idiom data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdiomProvider>().selectIdiom(widget.idiomId);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final idiomProvider = context.watch<IdiomProvider>();
    final idiom = idiomProvider.selectedIdiom;

    if (idiom == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppConstants.teal),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Header ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor:
                isDark ? AppConstants.slateDark : AppConstants.warmWhite,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white)
                      .withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : AppConstants.slateDark,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Share button
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white)
                        .withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, size: 20),
                ),
                onPressed: () => _shareIdiom(context),
              ),
              // Favorite button
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white)
                        .withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    idiom.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: idiom.isFavorite
                        ? AppConstants.amber
                        : null,
                    size: 22,
                  ),
                ),
                onPressed: () => _toggleFavorite(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppConstants.tealDark.withValues(alpha: 0.4),
                            AppConstants.slateDark,
                          ]
                        : [
                            AppConstants.teal.withValues(alpha: 0.12),
                            AppConstants.warmWhite,
                          ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Watermark
                    Positioned(
                      right: -30,
                      top: -20,
                      child: Icon(
                        Icons.format_quote_rounded,
                        size: 200,
                        color: AppConstants.teal
                            .withValues(alpha: isDark ? 0.05 : 0.04),
                      ),
                    ),
                    // Idiom name
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 24,
                      child: FadeTransition(
                        opacity: _animController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category + difficulty
                            Row(
                              children: [
                                _buildCategoryChip(
                                  idiom.category,
                                  isDark,
                                ),
                                const SizedBox(width: 8),
                                DifficultyBadge(
                                  difficulty: idiom.difficulty,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              idiom.idiom,
                              style:
                                  theme.textTheme.displaySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                height: 1.2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animController,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: _animController,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Meaning ──────────────────────────────
                      _DetailSection(
                        icon: Icons.lightbulb_rounded,
                        iconColor: AppConstants.amber,
                        title: 'Meaning',
                        content: idiom.meaning,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),

                      // ── Explanation ──────────────────────────
                      _DetailSection(
                        icon: Icons.menu_book_rounded,
                        iconColor: AppConstants.teal,
                        title: 'Explanation',
                        content: idiom.explanation,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),

                      // ── Example ──────────────────────────────
                      _ExampleSection(
                        example: idiom.example,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),

                      // ── Usage ────────────────────────────────
                      _DetailSection(
                        icon: Icons.chat_bubble_rounded,
                        iconColor: AppConstants.intermediateBlue,
                        title: 'Usage',
                        content: _formatUsage(idiom.usage),
                        isDark: isDark,
                      ),

                      // ── Origin ───────────────────────────────
                      if (idiom.origin.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _DetailSection(
                          icon: Icons.history_edu_rounded,
                          iconColor: AppConstants.advancedPurple,
                          title: 'Origin',
                          content: idiom.origin,
                          isDark: isDark,
                        ),
                      ],

                      // ── Related Expressions ──────────────────
                      if (idiom.related.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildRelatedExpressions(context, idiom.related),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isDark) {
    final categoryData = AppConstants.categories.firstWhere(
      (c) => c['name'] == category,
      orElse: () => {
        'name': category,
        'color': AppConstants.teal,
        'icon': Icons.label,
      },
    );
    final color = categoryData['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categoryData['icon'] as IconData, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedExpressions(
      BuildContext context, List<String> related) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.link_rounded,
              size: 20,
              color: AppConstants.teal,
            ),
            const SizedBox(width: 8),
            Text(
              'Related Expressions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: related.map((expr) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppConstants.slateMid
                    : AppConstants.warmGray,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
                border: Border.all(
                  color: isDark
                      ? AppConstants.slateLight.withValues(alpha: 0.3)
                      : AppConstants.warmGrayMid,
                ),
              ),
              child: Text(
                expr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatUsage(String usage) {
    switch (usage.toLowerCase()) {
      case 'formal':
        return '🎩 Formal — Suitable for professional and academic contexts.';
      case 'informal':
        return '👋 Informal — Best used in casual conversations.';
      case 'both':
        return '✅ Versatile — Can be used in both formal and informal settings.';
      default:
        return usage;
    }
  }

  void _shareIdiom(BuildContext context) {
    final idiom = context.read<IdiomProvider>().selectedIdiom;
    if (idiom == null) return;

    SharePlus.instance.share(
      ShareParams(
        text: '🔎 ${idiom.idiom}\n\n'
            '💡 Meaning: ${idiom.meaning}\n\n'
            '📖 Example: ${idiom.example}\n\n'
            '— Shared from Idiom Detective 🕵️',
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final idiom = context.read<IdiomProvider>().selectedIdiom;
    if (idiom == null) return;

    final favProvider = context.read<FavoritesProvider>();
    final isFav = await favProvider.toggleFavorite(idiom.id);
    if (mounted) {
      context.read<IdiomProvider>().updateIdiomFavoriteState(idiom.id, isFav);
    }
  }
}

// ─── Detail Section Widget ───────────────────────────────────────

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final bool isDark;

  const _DetailSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.7,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppConstants.slateDark.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Example Section Widget ──────────────────────────────────────

class _ExampleSection extends StatelessWidget {
  final String example;
  final bool isDark;

  const _ExampleSection({
    required this.example,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: isDark
            ? AppConstants.amber.withValues(alpha: 0.08)
            : AppConstants.amber.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppConstants.amber.withValues(alpha: isDark ? 0.2 : 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                size: 20,
                color: AppConstants.amber,
              ),
              const SizedBox(width: 8),
              Text(
                'Example',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppConstants.amberDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '"$example"',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
