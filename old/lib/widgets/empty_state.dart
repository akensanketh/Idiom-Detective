import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A reusable empty state widget with illustration, title, and subtitle.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.teal.withValues(alpha: isDark ? 0.15 : 0.1),
                    AppConstants.teal.withValues(alpha: 0.0),
                  ],
                  radius: 0.8,
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark
                    ? AppConstants.slateText
                    : AppConstants.warmGrayDark,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSm),

            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppConstants.slateText
                    : AppConstants.warmGrayDark,
              ),
              textAlign: TextAlign.center,
            ),

            // Optional action button
            if (buttonLabel != null && onButtonTap != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              ElevatedButton.icon(
                onPressed: onButtonTap,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
