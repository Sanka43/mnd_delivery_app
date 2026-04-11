import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnd_core/mnd_core.dart';
import 'package:mnd_theme/mnd_theme.dart';

import 'data/user_profile_repo.dart';
import 'features/auth/admin_login_page.dart';
import 'features/auth/admin_welcome_page.dart';
import 'features/shell/admin_shell_page.dart';

class MndAdminApp extends StatelessWidget {
  const MndAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MND Admin',
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
          return _AdminRoleGate(user: snap.data!);
        }
        return const _AdminUnauthenticatedFlow();
      },
    );
  }
}

/// Welcome → login (reference UI); both routes share the same Firebase session.
class _AdminUnauthenticatedFlow extends StatefulWidget {
  const _AdminUnauthenticatedFlow();

  @override
  State<_AdminUnauthenticatedFlow> createState() =>
      _AdminUnauthenticatedFlowState();
}

class _AdminUnauthenticatedFlowState extends State<_AdminUnauthenticatedFlow> {
  bool _showLogin = false;

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return AdminLoginPage(
        onBack: () => setState(() => _showLogin = false),
      );
    }
    return AdminWelcomePage(
      onLogin: () => setState(() => _showLogin = true),
    );
  }
}

class _AdminRoleGate extends StatefulWidget {
  const _AdminRoleGate({required this.user});

  final User user;

  @override
  State<_AdminRoleGate> createState() => _AdminRoleGateState();
}

class _AdminRoleGateState extends State<_AdminRoleGate> {
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
        if (role != UserRole.admin) {
          return MndLoginChrome(
            headline: 'MND Admin',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'This account is not an admin. Set Firestore '
                  'users/${widget.user.uid} with role "admin".',
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

        return AdminShellPage(user: widget.user);
      },
    );
  }
}
