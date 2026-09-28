import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// App theme configuration — Classic Mystery Noir & Modern Teal.
///
/// Dark mode: deep slate navy surfaces with teal and amber accents.
/// Light mode: warm off-white with rich teal primary and amber highlights.
class AppTheme {
  AppTheme._();

  // ─── Dark Theme ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppConstants.teal,
      onPrimary: Colors.white,
      primaryContainer: AppConstants.tealDark,
      onPrimaryContainer: AppConstants.tealLight,
      secondary: AppConstants.amber,
      onSecondary: AppConstants.slateDarkest,
      secondaryContainer: AppConstants.amberDark,
      onSecondaryContainer: AppConstants.amberLight,
      surface: AppConstants.slateMid,
      onSurface: Colors.white,
      error: AppConstants.errorRed,
      onError: Colors.white,
      outline: AppConstants.slateLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppConstants.slateDark,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.slateDark,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppConstants.slateDarkest,
        selectedItemColor: AppConstants.tealLight,
        unselectedItemColor: AppConstants.slateText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.slateMid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: BorderSide(
            color: AppConstants.slateLight.withValues(alpha: 0.3),
          ),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppConstants.slateLight.withValues(alpha: 0.3),
        selectedColor: AppConstants.teal.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.slateMid,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(
            color: AppConstants.slateLight.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: AppConstants.teal, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppConstants.slateText,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        prefixIconColor: AppConstants.slateText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.tealLight,
          side: const BorderSide(color: AppConstants.teal),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.amber,
        foregroundColor: AppConstants.slateDarkest,
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: AppConstants.slateLight.withValues(alpha: 0.3),
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppConstants.slateMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.slateMid,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppConstants.teal,
        linearTrackColor: AppConstants.slateLight,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppConstants.teal;
          }
          return AppConstants.slateText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppConstants.teal.withValues(alpha: 0.3);
          }
          return AppConstants.slateLight;
        }),
      ),
    );
  }

  // ─── Light Theme ────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppConstants.tealDark,
      onPrimary: Colors.white,
      primaryContainer: AppConstants.teal.withValues(alpha: 0.12),
      onPrimaryContainer: AppConstants.tealDark,
      secondary: AppConstants.amberDark,
      onSecondary: Colors.white,
      secondaryContainer: AppConstants.amber.withValues(alpha: 0.15),
      onSecondaryContainer: AppConstants.amberDark,
      surface: Colors.white,
      onSurface: AppConstants.slateDark,
      error: AppConstants.errorRed,
      onError: Colors.white,
      outline: AppConstants.warmGrayMid,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppConstants.warmWhite,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.warmWhite,
        foregroundColor: AppConstants.slateDark,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppConstants.slateDark,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppConstants.tealDark,
        unselectedItemColor: AppConstants.warmGrayDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: BorderSide(color: AppConstants.warmGrayMid.withValues(alpha: 0.5)),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppConstants.warmGray,
        selectedColor: AppConstants.teal.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppConstants.slateDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        side: BorderSide(color: AppConstants.warmGrayMid.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.warmGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(
            color: AppConstants.warmGrayMid.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: AppConstants.tealDark, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppConstants.warmGrayDark,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        prefixIconColor: AppConstants.warmGrayDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.tealDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.tealDark,
          side: const BorderSide(color: AppConstants.tealDark),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.amberDark,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: AppConstants.warmGrayMid.withValues(alpha: 0.5),
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.slateDark,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppConstants.tealDark,
        linearTrackColor: AppConstants.warmGrayMid,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppConstants.tealDark;
          }
          return AppConstants.warmGrayDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppConstants.teal.withValues(alpha: 0.3);
          }
          return AppConstants.warmGrayMid;
        }),
      ),
    );
  }

  // ─── Text Theme ─────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.white
        : AppConstants.slateDark;
    final mutedColor = brightness == Brightness.dark
        ? AppConstants.slateText
        : AppConstants.warmGrayDark;

    return TextTheme(
      // Headlines - Outfit for display/headings
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),

      // Title - Inter for UI elements
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),

      // Body - Inter for readability
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedColor,
        height: 1.5,
      ),

      // Labels
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: mutedColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
