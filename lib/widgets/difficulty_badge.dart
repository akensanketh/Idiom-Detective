import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A compact badge that displays the difficulty level with appropriate color.
class DifficultyBadge extends StatelessWidget {
  final String difficulty;
  final bool showIcon;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.showIcon = true,
  });

  Color get _color {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppConstants.beginnerGreen;
      case 'intermediate':
        return AppConstants.intermediateBlue;
      case 'advanced':
        return AppConstants.advancedPurple;
      default:
        return AppConstants.intermediateBlue;
    }
  }

  IconData get _icon {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Icons.star_border_rounded;
      case 'intermediate':
        return Icons.star_half_rounded;
      case 'advanced':
        return Icons.star_rounded;
      default:
        return Icons.star_half_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_icon, size: 12, color: _color),
            const SizedBox(width: 3),
          ],
          Text(
            difficulty.toLowerCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
