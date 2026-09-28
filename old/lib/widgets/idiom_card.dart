import 'package:flutter/material.dart';
import '../models/idiom.dart';
import '../utils/constants.dart';
import 'difficulty_badge.dart';

/// A beautifully styled card for displaying an idiom in lists.
///
/// Shows the idiom name, meaning preview, category chip, difficulty badge,
/// and a favorite indicator with a tappable area.
class IdiomCard extends StatelessWidget {
  final Idiom idiom;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showCategory;

  const IdiomCard({
    super.key,
    required this.idiom,
    this.onTap,
    this.onFavorite,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header: Idiom name + Favorite ──────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Magnifying glass icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.teal.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Icon(
                      Icons.format_quote_rounded,
                      color: AppConstants.teal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Idiom name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          idiom.idiom,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          idiom.meaning,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppConstants.slateText
                                : AppConstants.warmGrayDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Favorite button
                  if (onFavorite != null)
                    GestureDetector(
                      onTap: onFavorite,
                      child: AnimatedContainer(
                        duration: AppConstants.animFast,
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          idiom.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: idiom.isFavorite
                              ? AppConstants.amber
                              : (isDark
                                  ? AppConstants.slateText
                                  : AppConstants.warmGrayDark),
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ─── Footer: Category + Difficulty ──────────────
              Row(
                children: [
                  if (showCategory) ...[
                    _CategoryChip(category: idiom.category),
                    const SizedBox(width: 8),
                  ],
                  DifficultyBadge(difficulty: idiom.difficulty),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark
                        ? AppConstants.slateText
                        : AppConstants.warmGrayDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryData['icon'] as IconData,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
