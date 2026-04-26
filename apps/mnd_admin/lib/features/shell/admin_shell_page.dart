import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mnd_theme/mnd_theme.dart';
import '../dashboard/dashboard_page.dart';
import '../placeholder/coming_soon_page.dart';
import '../settings/global_settings_page.dart';
import '../shops/shops_page.dart';
import 'admin_shell_header.dart';

/// Main admin layout: left navigation, shell header, content.
class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key, required this.user});

  final User user;

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;
}

class _AdminShellPageState extends State<AdminShellPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  late final List<_NavItem> _items = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      builder: (ctx) => DashboardPage(
        onOpenSection: (i) => setState(() => _index = i),
      ),
    ),
    _NavItem(
      label: 'Users',
      icon: Icons.people_outline,
      selectedIcon: Icons.people_rounded,
      builder: (_) => const ComingSoonPage(
        title: 'Users',
        description:
            'Customers, shop owners, and staff — search, block, and edit '
            'profiles from one place.',
      ),
    ),
    _NavItem(
      label: 'Shops',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront_rounded,
      builder: (_) => const ShopsPage(),
    ),
    _NavItem(
      label: 'Riders',
      icon: Icons.pedal_bike_outlined,
      selectedIcon: Icons.pedal_bike_rounded,
      builder: (_) => const ComingSoonPage(
        title: 'Riders',
        description:
            'Approve riders, see online status, assign orders, and review '
            'performance.',
      ),
    ),
    _NavItem(
      label: 'Orders',
      icon: Icons.list_alt_outlined,
      selectedIcon: Icons.list_alt_rounded,
      builder: (_) => const ComingSoonPage(
        title: 'Orders',
        description:
            'Full order lifecycle: filter by status, assign riders, and open '
            'pricing breakdowns.',
      ),
    ),
    _NavItem(
      label: 'Payments',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet_rounded,
      builder: (_) => const ComingSoonPage(
        title: 'Payments & settlements',
        description:
            'Earnings splits, rider cash collected vs payable to admin, and '
            'transaction logs.',
      ),
    ),
    _NavItem(
      label: 'Reports',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics_rounded,
      builder: (_) => const ComingSoonPage(
        title: 'Reports',
        description:
            'Daily revenue, rider earnings, and order summaries with date and '
            'entity filters.',
      ),
    ),
    _NavItem(
      label: 'Settings',
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune_rounded,
      builder: (_) => const GlobalSettingsPage(),
    ),
  ];

  Future<void> _signOut() => FirebaseAuth.instance.signOut();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= 840;
    final railExtended = width >= 1040;

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(
        key: ValueKey(_index),
        child: _items[_index].builder(context),
      ),
    );

    final glassChrome = mndGlassChromeEnabled;

    final rail = NavigationRail(
      extended: railExtended,
      backgroundColor:
          glassChrome ? Colors.transparent : scheme.surfaceContainerLow,
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      labelType: railExtended
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.none,
      leading: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
        child: railExtended
            ? Row(
                children: [
                  Icon(Icons.admin_panel_settings_rounded,
                      color: scheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'MND Admin',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              )
            : Icon(Icons.admin_panel_settings_rounded,
                color: scheme.primary, size: 28),
      ),
      destinations: [
        for (final item in _items)
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: Text(item.label),
          ),
      ],
    );

    final shellHeader = AdminShellHeader(
      scheme: scheme,
      user: widget.user,
      useRail: useRail,
      glassChrome: glassChrome,
      onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      onBell: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No new notifications'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onGoDashboard: () => setState(() => _index = 0),
      dashboardSelected: _index == 0,
      railUserMenu: useRail
          ? _UserMenu(
              email: widget.user.email ?? widget.user.uid,
              onSignOut: _signOut,
              compact: width < 520,
            )
          : null,
    );

    final drawerNav = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DrawerBrand(scheme: scheme),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _items.length,
            itemBuilder: (context, i) {
              final item = _items[i];
              final selected = i == _index;
              return ListTile(
                leading: Icon(
                  selected ? item.selectedIcon : item.icon,
                ),
                title: Text(item.label),
                selected: selected,
                onTap: () {
                  setState(() => _index = i);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.logout_rounded, color: scheme.error),
          title: Text(
            'Sign out',
            style: TextStyle(
              color: scheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _signOut();
          },
        ),
      ],
    );

    final drawer = useRail
        ? null
        : glassChrome
            ? Drawer(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                    child: MndGlassPanel(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(22),
                        bottomRight: Radius.circular(22),
                      ),
                      child: drawerNav,
                    ),
                  ),
                ),
              )
            : Drawer(
                child: SafeArea(child: drawerNav),
              );

    final body = Row(
      children: [
        if (useRail)
          glassChrome ? MndGlassRailBackdrop(child: rail) : rail,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              shellHeader,
              Expanded(child: content),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: glassChrome ? Colors.transparent : null,
      drawer: drawer,
      body: glassChrome
          ? Stack(
              fit: StackFit.expand,
              children: [
                const MndGlassBackdrop(),
                body,
              ],
            )
          : body,
    );
  }
}

class _DrawerBrand extends StatelessWidget {
  const _DrawerBrand({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Icon(Icons.admin_panel_settings_rounded,
              color: scheme.primary, size: 32),
          const SizedBox(width: 12),
          Text(
            'MND Admin',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _UserMenu extends StatelessWidget {
  const _UserMenu({
    required this.email,
    required this.onSignOut,
    this.compact = false,
  });

  final String email;
  final VoidCallback onSignOut;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.logout_rounded),
          onPressed: onSignOut,
          child: const Text('Sign out'),
        ),
      ],
      builder: (context, controller, child) {
        final trigger = InkWell(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 12,
              vertical: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: compact ? 16 : 18,
                  child: Text(
                    email.isNotEmpty ? email[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: compact ? 13 : 14),
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.expand_more_rounded, size: 20),
                ],
              ],
            ),
          ),
        );
        if (compact) {
          return Tooltip(message: email, child: trigger);
        }
        return trigger;
      },
    );
  }
}
