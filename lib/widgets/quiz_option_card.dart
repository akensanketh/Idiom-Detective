import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// An answer option card for quiz screens.
///
/// Displays the option text with dynamic coloring based on
/// whether the answer has been selected and whether it's correct.
class QuizOptionCard extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool isRevealed;
  final VoidCallback? onTap;

  const QuizOptionCard({
    super.key,
    required this.text,
    required this.index,
    this.isSelected = false,
    this.isCorrect = false,
    this.isRevealed = false,
    this.onTap,
  });

  Color _getBackgroundColor(bool isDark) {
    if (!isRevealed) {
      if (isSelected) {
        return AppConstants.teal.withValues(alpha: 0.15);
      }
      return isDark ? AppConstants.slateMid : Colors.white;
    }

    // Revealed state
    if (isCorrect) {
      return AppConstants.successGreen.withValues(alpha: isDark ? 0.15 : 0.1);
    }
    if (isSelected && !isCorrect) {
      return AppConstants.errorRed.withValues(alpha: isDark ? 0.15 : 0.1);
    }
    return isDark
        ? AppConstants.slateMid.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.5);
  }

  Color _getBorderColor(bool isDark) {
    if (!isRevealed) {
      if (isSelected) return AppConstants.teal;
      return isDark
          ? AppConstants.slateLight.withValues(alpha: 0.3)
          : AppConstants.warmGrayMid;
    }

    if (isCorrect) return AppConstants.successGreen;
    if (isSelected && !isCorrect) return AppConstants.errorRed;
    return isDark
        ? AppConstants.slateLight.withValues(alpha: 0.15)
        : AppConstants.warmGrayMid.withValues(alpha: 0.5);
  }

  IconData? _getIcon() {
    if (!isRevealed) return null;
    if (isCorrect) return Icons.check_circle_rounded;
    if (isSelected && !isCorrect) return Icons.cancel_rounded;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final icon = _getIcon();

    return GestureDetector(
      onTap: isRevealed ? null : onTap,
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: _getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: _getBorderColor(isDark),
            width: isSelected || (isRevealed && isCorrect) ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Option letter (A, B, C, D)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected || (isRevealed && isCorrect)
                    ? _getBorderColor(isDark).withValues(alpha: 0.15)
                    : (isDark
                        ? AppConstants.slateLight.withValues(alpha: 0.2)
                        : AppConstants.warmGray),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected || (isRevealed && isCorrect)
                        ? _getBorderColor(isDark)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Option text
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight:
                      isSelected || (isRevealed && isCorrect)
                          ? FontWeight.w600
                          : FontWeight.w400,
                  color: isRevealed && !isCorrect && !isSelected
                      ? (isDark
                          ? AppConstants.slateText.withValues(alpha: 0.5)
                          : AppConstants.warmGrayDark.withValues(alpha: 0.5))
                      : null,
                ),
              ),
            ),

            // Result icon
            if (icon != null)
              Icon(
                icon,
                color: isCorrect
                    ? AppConstants.successGreen
                    : AppConstants.errorRed,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
