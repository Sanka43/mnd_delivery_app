import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnd_core/mnd_core.dart';
import 'package:mnd_theme/mnd_theme.dart';

import 'data/user_profile_repo.dart';
import 'features/auth/shop_login_page.dart';
import 'features/orders/shop_home_page.dart';

class MndShopApp extends StatelessWidget {
  const MndShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MND Shop',
      debugShowCheckedModeBanner: false,
      theme: MndAppTheme.light,
      darkTheme: MndAppTheme.dark,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final theme = Theme.of(context);
        final dark = theme.brightness == Brightness.dark;
        final overlay = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: theme.colorScheme.surface,
          systemNavigationBarIconBrightness:
              dark ? Brightness.light : Brightness.dark,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.data != null) {
          return _ShopRoleGate(user: snap.data!);
        }
        return const ShopLoginPage();
      },
    );
  }
}

class _ShopRoleGate extends StatefulWidget {
  const _ShopRoleGate({required this.user});

  final User user;

  @override
  State<_ShopRoleGate> createState() => _ShopRoleGateState();
}

class _ShopRoleGateState extends State<_ShopRoleGate> {
  final _repo = UserProfileRepo();
  late Future<UserRole?> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.roleFor(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final role = snapshot.data;
        if (role != UserRole.shop) {
          return MndLoginChrome(
            headline: 'MND Shop',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'This account is not a shop. Set Firestore '
                  'users/${widget.user.uid} with role "shop".',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          );
        }
        return ShopHomePage(user: widget.user);
      },
    );
  }
}
