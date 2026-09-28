import 'package:flutter/material.dart';

/// App-wide constants: colors, sizes, text styles, categories, etc.
class AppConstants {
  AppConstants._();

  // ─── App Identity ───────────────────────────────────────────────
  static const String appName = 'Idiom Detective';
  static const String tagline = 'Crack the meaning behind every expression.';

  // ─── Color Palette: Classic Mystery Noir & Modern Teal ──────────
  // Primary: Detective Teal
  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF14B8A6);
  static const Color tealDark = Color(0xFF0F766E);

  // Accent: Magnifying Amber
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color amberDark = Color(0xFFD97706);

  // Dark Mode Surfaces
  static const Color slateDarkest = Color(0xFF0B1120);
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateMid = Color(0xFF1E293B);
  static const Color slateLight = Color(0xFF334155);
  static const Color slateText = Color(0xFF94A3B8);

  // Light Mode Surfaces
  static const Color warmWhite = Color(0xFFFFFBF5);
  static const Color warmGray = Color(0xFFF8FAFC);
  static const Color warmGrayMid = Color(0xFFE2E8F0);
  static const Color warmGrayDark = Color(0xFF64748B);

  // Status / Difficulty Colors
  static const Color beginnerGreen = Color(0xFF22C55E);
  static const Color intermediateBlue = Color(0xFF3B82F6);
  static const Color advancedPurple = Color(0xFFA855F7);

  // Error / Warning
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);

  // ─── Spacing ────────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ─── Border Radius ─────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ─── Animation Durations ────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);

  // ─── Categories ─────────────────────────────────────────────────
  static const List<Map<String, dynamic>> categories = [
    {'name': 'Animals', 'icon': Icons.pets, 'color': Color(0xFF22C55E)},
    {'name': 'Body Parts', 'icon': Icons.accessibility_new, 'color': Color(0xFFEF4444)},
    {'name': 'Food & Drink', 'icon': Icons.restaurant, 'color': Color(0xFFF59E0B)},
    {'name': 'Colors', 'icon': Icons.palette, 'color': Color(0xFFA855F7)},
    {'name': 'Weather & Nature', 'icon': Icons.wb_sunny, 'color': Color(0xFF06B6D4)},
    {'name': 'Money & Business', 'icon': Icons.attach_money, 'color': Color(0xFF10B981)},
    {'name': 'Time', 'icon': Icons.access_time, 'color': Color(0xFF6366F1)},
    {'name': 'Emotions', 'icon': Icons.emoji_emotions, 'color': Color(0xFFEC4899)},
    {'name': 'Actions', 'icon': Icons.directions_run, 'color': Color(0xFF14B8A6)},
    {'name': 'Communication', 'icon': Icons.chat_bubble, 'color': Color(0xFF8B5CF6)},
    {'name': 'Work & Effort', 'icon': Icons.work, 'color': Color(0xFF3B82F6)},
    {'name': 'Relationships', 'icon': Icons.people, 'color': Color(0xFFF43F5E)},
    {'name': 'Health', 'icon': Icons.favorite, 'color': Color(0xFFFB7185)},
    {'name': 'Home & Family', 'icon': Icons.home, 'color': Color(0xFFD97706)},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Color(0xFF0EA5E9)},
    {'name': 'Conflict', 'icon': Icons.flash_on, 'color': Color(0xFFDC2626)},
    {'name': 'Sports & Games', 'icon': Icons.sports_soccer, 'color': Color(0xFF65A30D)},
    {'name': 'Knowledge', 'icon': Icons.school, 'color': Color(0xFF7C3AED)},
    {'name': 'Luck & Chance', 'icon': Icons.casino, 'color': Color(0xFFE11D48)},
    {'name': 'Truth & Deception', 'icon': Icons.visibility, 'color': Color(0xFF0891B2)},
    {'name': 'Success & Failure', 'icon': Icons.trending_up, 'color': Color(0xFF059669)},
    {'name': 'Anger', 'icon': Icons.whatshot, 'color': Color(0xFFEA580C)},
    {'name': 'Fear & Courage', 'icon': Icons.shield, 'color': Color(0xFF4F46E5)},
    {'name': 'Clothing', 'icon': Icons.checkroom, 'color': Color(0xFFDB2777)},
    {'name': 'Water & Sea', 'icon': Icons.water, 'color': Color(0xFF0284C7)},
    {'name': 'General Wisdom', 'icon': Icons.lightbulb, 'color': Color(0xFFF59E0B)},
  ];

  // ─── Difficulty Levels ──────────────────────────────────────────
  static const List<Map<String, dynamic>> difficulties = [
    {'name': 'Beginner', 'color': beginnerGreen, 'icon': Icons.star_border},
    {'name': 'Intermediate', 'color': intermediateBlue, 'icon': Icons.star_half},
    {'name': 'Advanced', 'color': advancedPurple, 'icon': Icons.star},
  ];

  // ─── Database ───────────────────────────────────────────────────
  static const String dbName = 'idiom_detective.db';
  static const int dbVersion = 1;
  static const String tableIdioms = 'idioms';
  static const String tableFavorites = 'favorites';
  static const String tableRecentlyViewed = 'recently_viewed';

  // ─── Shared Preferences Keys ───────────────────────────────────
  static const String prefThemeMode = 'theme_mode';
  static const String prefDailyIdiomDate = 'daily_idiom_date';
  static const String prefDailyIdiomId = 'daily_idiom_id';
  static const String prefQuizHighScore = 'quiz_high_score';
  static const String prefDetectiveScore = 'detective_score';
  static const String prefTotalQuizzes = 'total_quizzes';
  static const String prefStreak = 'streak';
  static const String prefLastStreakDate = 'last_streak_date';

  // ─── Quiz Settings ─────────────────────────────────────────────
  static const int quizQuestionCount = 10;
  static const int quizOptionsCount = 4;
  static const int detectiveChallengeCount = 15;
  static const int quizTimerSeconds = 20;
}
