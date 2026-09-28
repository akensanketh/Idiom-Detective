import 'package:flutter/material.dart';
import '../models/idiom.dart';
import '../utils/constants.dart';

/// A prominent card for the Daily Case feature on the home screen.
///
/// Shows a "case file" style card with today's idiom teaser,
/// a magnifying glass icon, and a "Crack the Case" button.
class DailyCaseCard extends StatelessWidget {
  final Idiom? idiom;
  final bool isNew;
  final VoidCallback? onTap;

  const DailyCaseCard({
    super.key,
    this.idiom,
    this.isNew = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (idiom == null) {
      return _buildLoadingState(context);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
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
            color: AppConstants.teal.withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppConstants.teal.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background magnifying glass watermark
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.search_rounded,
                size: 120,
                color: AppConstants.teal.withValues(alpha: isDark ? 0.06 : 0.04),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConstants.teal.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: const Icon(
                          Icons.cases_rounded,
                          color: AppConstants.teal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TODAY'S CASE",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppConstants.teal,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Daily Mystery',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.amber,
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Text(
                            'NEW',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppConstants.slateDarkest,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Idiom name
                  Text(
                    '"${idiom!.idiom}"',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppConstants.tealLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Teaser
                  Text(
                    'Can you crack the meaning?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppConstants.slateText
                          : AppConstants.warmGrayDark,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CTA Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.teal,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusFull),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.teal.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Crack the Case',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildLoadingState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.slateMid : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(
          color: AppConstants.teal.withValues(alpha: 0.2),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppConstants.teal,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
