import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnd_core/mnd_core.dart';

import 'home_feed_view.dart';
import 'tabs/placeholder_tab.dart';
import 'tabs/profile_tab.dart';

/// Main customer shell: reference-style home feed + floating bottom navigation.
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({
    super.key,
    required this.user,
    this.activeOrderStatus,
  });

  final User user;

  final OrderStatus? activeOrderStatus;

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      extendBody: true,
      body: IndexedStack(
        index: _navIndex,
        alignment: Alignment.topCenter,
        children: [
          HomeFeedView(activeOrderStatus: widget.activeOrderStatus),
          const PlaceholderTab(
            title: 'Favorites',
            icon: Icons.favorite_outline_rounded,
          ),
          const PlaceholderTab(
            title: 'Cart',
            icon: Icons.shopping_cart_outlined,
          ),
          const PlaceholderTab(
            title: 'Orders',
            icon: Icons.confirmation_number_outlined,
          ),
          ProfileTab(user: widget.user),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Material(
          elevation: 6,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(28),
          color: cs.surface,
          clipBehavior: Clip.antiAlias,
          child: NavigationBar(
            height: 64,
            selectedIndex: _navIndex,
            backgroundColor: cs.surface,
            indicatorColor: cs.primaryContainer,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (i) {
              setState(() => _navIndex = i);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline_rounded),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: 'Favorites',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart_rounded),
                label: 'Cart',
              ),
              NavigationDestination(
                icon: Icon(Icons.confirmation_number_outlined),
                selectedIcon: Icon(Icons.confirmation_number_rounded),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
