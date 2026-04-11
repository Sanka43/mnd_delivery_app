import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

/// Shared header for every admin tab: avatar (drawer menu on narrow screens),
/// greeting, tappable area → dashboard, notifications, optional rail user menu.
class AdminShellHeader extends StatelessWidget {
  const AdminShellHeader({
    super.key,
    required this.scheme,
    required this.user,
    required this.useRail,
    required this.glassChrome,
    required this.onOpenDrawer,
    required this.onBell,
    required this.onGoDashboard,
    required this.dashboardSelected,
    this.railUserMenu,
  });

  final ColorScheme scheme;
  final User user;
  final bool useRail;
  final bool glassChrome;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBell;
  final VoidCallback onGoDashboard;
  final bool dashboardSelected;
  final Widget? railUserMenu;

  static String helloFirstName(User user) {
    final name = user.displayName?.trim();
    final email = user.email?.trim();
    if (name != null && name.isNotEmpty) return name.split(' ').first;
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    final helloName = helloFirstName(user);
    final letter =
        (user.email ?? user.displayName ?? '?')[0].toUpperCase();
    final drawerMode = !useRail;

    final avatar = CircleAvatar(
      radius: 26,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final avatarControl = Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: drawerMode ? onOpenDrawer : () {},
        child: avatar,
      ),
    );

    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        );

    final inner = Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          drawerMode
              ? Tooltip(message: 'Menu', child: avatarControl)
              : avatar,
          const SizedBox(width: 14),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onGoDashboard,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello $helloName,',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        dashboardSelected
                            ? 'Welcome back!'
                            : 'Dashboard',
                        style: dashboardSelected
                            ? titleStyle
                            : titleStyle?.copyWith(
                                color: scheme.primary,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    scheme.primary.withValues(alpha: 0.4),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: scheme.surfaceContainerLowest,
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBell,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.notifications_outlined,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
          if (railUserMenu != null) ...[
            const SizedBox(width: 8),
            railUserMenu!,
          ],
        ],
      ),
    );

    if (glassChrome) {
      return MndGlassPanel(
        borderRadius: BorderRadius.zero,
        border: Border(
          bottom: BorderSide(
            color: scheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: inner,
        ),
      );
    }

    return Material(
      elevation: 0,
      color: scheme.surface,
      child: SafeArea(
        bottom: false,
        child: inner,
      ),
    );
  }
}
