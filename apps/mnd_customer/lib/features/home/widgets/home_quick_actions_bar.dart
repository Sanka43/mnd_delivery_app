import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

/// One shortcut on the home feed (Food, Market, ...).
class HomeQuickActionData {
  const HomeQuickActionData({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconAssetPath,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final String? iconAssetPath;
  final VoidCallback onPressed;

  /// Retained for API compatibility and optional subdued styling.
  final bool outlined;
}

/// Horizontal row of quick actions with icon + label only.
class HomeQuickActionsBar extends StatelessWidget {
  const HomeQuickActionsBar({
    super.key,
    required this.actions,
    this.spacing = 12,
  });

  final List<HomeQuickActionData> actions;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(
              child: _QuickActionTile(data: actions[i], index: i),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.data, required this.index});

  final HomeQuickActionData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    const iconPalette = <Color>[
      MndBrandColors.tealBlue,
      MndBrandColors.royal,
      Color(0xFF5E8BFF),
      Color(0xFF31CBA0),
      Color(0xFF7A7CFF),
      Color(0xFF35B2FF),
    ];
    final baseColor = iconPalette[index % iconPalette.length];
    final iconColor = data.outlined
        ? baseColor.withValues(alpha: 0.8)
        : baseColor;
    final labelColor = isDark ? cs.onSurface : MndBrandColors.navy;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data.iconAssetPath case final String assetPath)
                Image.asset(
                  assetPath,
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                )
              else
                _CartoonActionIcon(
                  icon: data.icon,
                  color: iconColor,
                  isDark: isDark,
                ),
              const SizedBox(height: 8),
              Text(
                data.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartoonActionIcon extends StatelessWidget {
  const _CartoonActionIcon({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            icon,
            size: 36,
            color: (isDark ? Colors.white : MndBrandColors.navy).withValues(
              alpha: isDark ? 0.9 : 0.92,
            ),
          ),
          Icon(icon, size: 30, color: color),
        ],
      ),
    );
  }
}
