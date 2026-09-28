import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../models/idiom.dart';
import '../../providers/daily_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/idiom_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/daily_case_card.dart';
import '../../widgets/idiom_card.dart';
import '../../widgets/search_field.dart';
import '../detail/idiom_detail_screen.dart';
import '../search/search_screen.dart';

/// The home screen — the detective's dashboard.
///
/// Features:
/// - Search bar (tap to navigate to full search)
/// - Daily Case card
/// - Random Idiom pick
/// - Recently Viewed list
/// - Quick category access
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final idiomProvider = context.watch<IdiomProvider>();
    final dailyProvider = context.watch<DailyProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ──────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppConstants.teal.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: AppConstants.teal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: theme.appBarTheme.titleTextStyle,
                    ),
                    Text(
                      AppConstants.tagline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? AppConstants.slateText
                            : AppConstants.warmGrayDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () =>
                    Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),

          // ─── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: AppConstants.animSlow,
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    const SizedBox(height: 8),

                    // ── Search Bar ─────────────────────────────
                    SearchField(
                      readOnly: true,
                      hintText: 'Search 1,000+ idioms...',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchScreen(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Daily Case ─────────────────────────────
                    DailyCaseCard(
                      idiom: dailyProvider.dailyIdiom,
                      isNew: dailyProvider.isNewDay,
                      onTap: () {
                        if (dailyProvider.dailyIdiom != null) {
                          _navigateToDetail(
                              context, dailyProvider.dailyIdiom!);
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Random Idiom ───────────────────────────
                    _buildSectionHeader(
                      context,
                      title: 'Random Discovery',
                      icon: Icons.shuffle_rounded,
                      actionLabel: 'New Pick',
                      onAction: () =>
                          idiomProvider.fetchRandomIdiom(),
                    ),
                    if (idiomProvider.randomIdiom != null)
                      _buildRandomIdiomCard(
                        context,
                        idiomProvider.randomIdiom!,
                      ),

                    const SizedBox(height: 24),

                    // ── Quick Stats ────────────────────────────
                    _buildQuickStats(context, idiomProvider),

                    const SizedBox(height: 24),

                    // ── Recently Viewed ────────────────────────
                    if (idiomProvider.recentlyViewed.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        title: 'Recently Viewed',
                        icon: Icons.history_rounded,
                        actionLabel: 'Clear',
                        onAction: () =>
                            idiomProvider.clearRecentlyViewed(),
                      ),
                      ...idiomProvider.recentlyViewed
                          .take(5)
                          .map((idiom) => _buildRecentIdiomTile(
                                context, idiom)),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppConstants.teal),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.teal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppConstants.tealLight
                      : AppConstants.tealDark,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRandomIdiomCard(BuildContext context, Idiom idiom) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favProvider = context.read<FavoritesProvider>();
    final idiomProvider = context.read<IdiomProvider>();

    return IdiomCard(
      idiom: idiom,
      onTap: () => _navigateToDetail(context, idiom),
      onFavorite: () async {
        final isFav = await favProvider.toggleFavorite(idiom.id);
        idiomProvider.updateIdiomFavoriteState(idiom.id, isFav);
      },
    );
  }

  Widget _buildQuickStats(BuildContext context, IdiomProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
      ),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.format_quote_rounded,
            label: 'Total Idioms',
            value: '${provider.totalCount}',
            color: AppConstants.teal,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.category_rounded,
            label: 'Categories',
            value: '${provider.categories.length}',
            color: AppConstants.amber,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.history_rounded,
            label: 'Viewed',
            value: '${provider.recentlyViewed.length}',
            color: AppConstants.intermediateBlue,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentIdiomTile(BuildContext context, Idiom idiom) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd + 4,
        vertical: 2,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppConstants.teal.withValues(alpha: isDark ? 0.1 : 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: const Icon(
          Icons.format_quote_rounded,
          color: AppConstants.teal,
          size: 18,
        ),
      ),
      title: Text(
        idiom.idiom,
        style: theme.textTheme.titleSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        idiom.meaning,
        style: theme.textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppConstants.slateText : AppConstants.warmGrayDark,
      ),
      onTap: () => _navigateToDetail(context, idiom),
    );
  }

  void _navigateToDetail(BuildContext context, Idiom idiom) {
    context.read<IdiomProvider>().selectIdiom(idiom.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IdiomDetailScreen(idiomId: idiom.id),
      ),
    );
  }
}

// ─── Quick Stat Card ────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.slateMid : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: isDark
                ? AppConstants.slateLight.withValues(alpha: 0.2)
                : AppConstants.warmGrayMid.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
