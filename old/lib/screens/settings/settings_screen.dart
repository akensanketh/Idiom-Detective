import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';

/// Settings screen — theme toggle, app info, and reset options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          // ─── Appearance ─────────────────────────────────────────
          _SectionHeader(title: 'Appearance', isDark: isDark),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconColor: AppConstants.advancedPurple,
                title: 'Dark Mode',
                subtitle: isDark ? 'On — Mystery Noir' : 'Off — Light Mode',
                isDark: isDark,
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
              _Divider(isDark: isDark),
              _SettingsTile(
                icon: Icons.palette_rounded,
                iconColor: AppConstants.teal,
                title: 'Theme',
                subtitle: _getThemeName(themeProvider.themeMode),
                isDark: isDark,
                onTap: () => _showThemePicker(context, themeProvider),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ─── About ──────────────────────────────────────────────
          _SectionHeader(title: 'About', isDark: isDark),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SettingsTile(
                icon: Icons.info_rounded,
                iconColor: AppConstants.intermediateBlue,
                title: AppConstants.appName,
                subtitle: 'Version 1.0.0',
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SettingsTile(
                icon: Icons.format_quote_rounded,
                iconColor: AppConstants.amber,
                title: 'Tagline',
                subtitle: AppConstants.tagline,
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SettingsTile(
                icon: Icons.code_rounded,
                iconColor: AppConstants.teal,
                title: 'Built with',
                subtitle: 'Flutter & Dart',
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ─── Data ───────────────────────────────────────────────
          _SectionHeader(title: 'Data', isDark: isDark),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SettingsTile(
                icon: Icons.storage_rounded,
                iconColor: AppConstants.beginnerGreen,
                title: 'Database',
                subtitle: 'Offline SQLite — 1,000+ idioms',
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark — Mystery Noir';
      case ThemeMode.light:
        return 'Light — Warm';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showThemePicker(
      BuildContext context, ThemeProvider themeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppConstants.slateMid : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppConstants.slateLight
                      : AppConstants.warmGrayMid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Theme',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              _ThemeOption(
                icon: Icons.dark_mode_rounded,
                name: 'Dark — Mystery Noir',
                isSelected: themeProvider.themeMode == ThemeMode.dark,
                isDark: isDark,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
              _ThemeOption(
                icon: Icons.light_mode_rounded,
                name: 'Light — Warm',
                isSelected: themeProvider.themeMode == ThemeMode.light,
                isDark: isDark,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              _ThemeOption(
                icon: Icons.settings_brightness_rounded,
                name: 'System Default',
                isSelected: themeProvider.themeMode == ThemeMode.system,
                isDark: isDark,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// ─── Supporting Widgets ──────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppConstants.slateText
                  : AppConstants.warmGrayDark,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.slateMid : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isDark
              ? AppConstants.slateLight.withValues(alpha: 0.2)
              : AppConstants.warmGrayMid.withValues(alpha: 0.5),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppConstants.slateText
                    : AppConstants.warmGrayDark,
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark
            ? AppConstants.slateLight.withValues(alpha: 0.15)
            : AppConstants.warmGrayMid.withValues(alpha: 0.5),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String name;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.teal.withValues(alpha: isDark ? 0.15 : 0.1)
              : (isDark ? AppConstants.slateMid : AppConstants.warmGray),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppConstants.teal
                : (isDark
                    ? AppConstants.slateLight.withValues(alpha: 0.2)
                    : AppConstants.warmGrayMid),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppConstants.teal : null, size: 22),
            const SizedBox(width: 14),
            Text(
              name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppConstants.teal : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppConstants.teal,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
