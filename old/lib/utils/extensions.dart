import 'package:flutter/material.dart';

/// Extension helpers used across the app.

extension StringExtensions on String {
  /// Capitalize the first letter of the string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert to title case (each word capitalized).
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Truncate with ellipsis if longer than [maxLength].
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }
}

extension ColorExtensions on Color {
  /// Create a lighter shade of this color.
  Color lighter([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Create a darker shade of this color.
  Color darker([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

extension ContextExtensions on BuildContext {
  /// Quick access to the current theme.
  ThemeData get theme => Theme.of(this);

  /// Quick access to the current color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Quick access to the current text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Quick access to screen size.
  Size get screenSize => MediaQuery.of(this).size;

  /// Is the current theme dark mode?
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Show a snack bar.
  void showSnack(String message, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color ?? Theme.of(this).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
