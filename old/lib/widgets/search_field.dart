import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A styled search text field with a magnifying glass icon.
class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String hintText;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.hintText = 'Search idioms...',
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppConstants.warmGrayMid)
                .withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        autofocus: autofocus,
        focusNode: focusNode,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.search_rounded, size: 22),
          ),
          suffixIcon: controller != null &&
                  controller!.text.isNotEmpty &&
                  onClear != null
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDark
                        ? AppConstants.slateText
                        : AppConstants.warmGrayDark,
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: isDark ? AppConstants.slateMid : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            borderSide: BorderSide(
              color: isDark
                  ? AppConstants.slateLight.withValues(alpha: 0.3)
                  : AppConstants.warmGrayMid.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            borderSide: const BorderSide(color: AppConstants.teal, width: 2),
          ),
        ),
      ),
    );
  }
}
