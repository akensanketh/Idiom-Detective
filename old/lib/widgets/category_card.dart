import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A styled category card with icon, name, count, and gradient accent.
class CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        decoration: BoxDecoration(
          color: isDark ? AppConstants.slateMid : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isDark
                ? AppConstants.slateLight.withValues(alpha: 0.3)
                : AppConstants.warmGrayMid.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient accent in top-right corner
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  // Name
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Count
                  Text(
                    '$count idiom${count == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppConstants.slateText
                          : AppConstants.warmGrayDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
