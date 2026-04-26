import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnd_core/mnd_core.dart';
import 'package:mnd_theme/mnd_theme.dart';

import '../food/food_page.dart';
import 'home_feed_view.dart';
import 'tabs/notifications_tab.dart';
import 'tabs/placeholder_tab.dart';
import 'tabs/profile_tab.dart';

/// Main customer shell — home feed + floating bottom navigation.
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({
    super.key,
    required this.user,
    required this.themeMode,
    required this.onThemeModeChanged,
    this.activeOrderStatus,
  });

  final User user;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  final OrderStatus? activeOrderStatus;

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _navIndex = 0;

  static const _tabSwitchDuration = Duration(milliseconds: 420);
  static const Curve _tabSwitchCurve = Curves.easeOutCubic;

  late final PageController _pageController;

  static const _labels = ['Home', 'Orders', 'Notifications', 'Profile'];

  static const _iconsOutlined = [
    Icons.home_outlined,
    Icons.confirmation_number_outlined,
    Icons.notifications_none_rounded,
    Icons.person_outline_rounded,
  ];

  static const _iconsSelected = [
    Icons.home_rounded,
    Icons.confirmation_number_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _navIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTab(int index) {
    if (_navIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _navIndex = index);
    _pageController.animateToPage(
      index,
      duration: _tabSwitchDuration,
      curve: _tabSwitchCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    // Light: elevated “card” bar; dark: deep surface that reads on dim UIs.
    final barDecoration = BoxDecoration(
      color: isDark ? cs.surfaceContainerHigh : Colors.white,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(
        color: isDark
            ? cs.outline.withValues(alpha: 0.35)
            : MndBrandColors.powder.withValues(alpha: 0.85),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: MndBrandColors.navy.withValues(alpha: isDark ? 0.45 : 0.12),
          blurRadius: isDark ? 24 : 20,
          offset: const Offset(0, 10),
          spreadRadius: isDark ? 0 : -2,
        ),
        if (!isDark)
          BoxShadow(
            color: MndBrandColors.royal.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
      ],
    );

    final selectedBg = isDark
        ? MndBrandColors.royal.withValues(alpha: 0.35)
        : MndBrandColors.royal.withValues(alpha: 0.12);
    final selectedFg = isDark ? cs.onPrimary : MndBrandColors.navy;
    final mutedFg = isDark
        ? cs.onSurface.withValues(alpha: 0.55)
        : MndBrandColors.blueMuted.withValues(alpha: 0.85);

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) {
          if (_navIndex != i) setState(() => _navIndex = i);
        },
        children: [
          HomeFeedView(
            key: const PageStorageKey<String>('tab_home'),
            user: widget.user,
            activeOrderStatus: widget.activeOrderStatus,
            onOpenFood: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const FoodPage(showBackButton: true),
                ),
              );
            },
            onOpenProfile: () => _goToTab(3),
          ),
          const PlaceholderTab(
            key: PageStorageKey<String>('tab_orders'),
            title: 'Orders',
            icon: Icons.confirmation_number_outlined,
          ),
          const NotificationsTab(
            key: PageStorageKey<String>('tab_notifications'),
          ),
          ProfileTab(
            key: const PageStorageKey<String>('tab_profile'),
            user: widget.user,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
        child: DecoratedBox(
          decoration: barDecoration,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: [
                for (var i = 0; i < _labels.length; i++)
                  Expanded(
                    child: _NavSlot(
                      label: _labels[i],
                      icon: _iconsOutlined[i],
                      selectedIcon: _iconsSelected[i],
                      selected: _navIndex == i,
                      selectedBg: selectedBg,
                      selectedFg: selectedFg,
                      mutedFg: mutedFg,
                      onTap: () => _goToTab(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.selectedBg,
    required this.selectedFg,
    required this.mutedFg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final Color selectedBg;
  final Color selectedFg;
  final Color mutedFg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: selectedFg.withValues(alpha: 0.08),
          highlightColor: selectedFg.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected ? selectedBg : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: selected ? 1.06 : 1,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    selected ? selectedIcon : icon,
                    size: 23,
                    color: selected ? selectedFg : mutedFg,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 9.5,
                      letterSpacing: selected ? -0.1 : 0,
                      color: selected ? selectedFg : mutedFg.withValues(alpha: 0.9),
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
