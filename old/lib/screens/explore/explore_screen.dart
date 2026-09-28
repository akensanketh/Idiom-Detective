import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/idiom_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/category_card.dart';
import 'all_idioms_screen.dart';
import 'category_idioms_screen.dart';

/// Explore screen — browse all idioms, by category, or by difficulty.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final idiomProvider = context.watch<IdiomProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AllIdiomsScreen(),
              ),
            ),
            icon: const Icon(Icons.list_rounded, size: 18),
            label: const Text('All'),
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.teal,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ─── Difficulty Filters ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By Difficulty',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: AppConstants.difficulties.map((diff) {
                      final name = diff['name'] as String;
                      final color = diff['color'] as Color;
                      final icon = diff['icon'] as IconData;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _DifficultyFilterCard(
                            name: name,
                            color: color,
                            icon: icon,
                            isDark: isDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AllIdiomsScreen(
                                  difficulty: name.toLowerCase(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ─── Categories Header ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.category_rounded,
                    size: 20,
                    color: AppConstants.amber,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Categories',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${idiomProvider.categories.length} categories',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          // ─── Category Grid ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final dbCategory = idiomProvider.categories[index];
                  final categoryName =
                      dbCategory['category'] as String;
                  final count = dbCategory['count'] as int;

                  // Find matching category data from constants
                  final categoryInfo =
                      AppConstants.categories.firstWhere(
                    (c) => c['name'] == categoryName,
                    orElse: () => {
                      'name': categoryName,
                      'icon': Icons.label_rounded,
                      'color': AppConstants.teal,
                    },
                  );

                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    columnCount: 2,
                    duration: AppConstants.animSlow,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: CategoryCard(
                          name: categoryName,
                          icon: categoryInfo['icon'] as IconData,
                          color: categoryInfo['color'] as Color,
                          count: count,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryIdiomsScreen(
                                category: categoryName,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: idiomProvider.categories.length,
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

class _DifficultyFilterCard extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _DifficultyFilterCard({
    required this.name,
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              name,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
