import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnd_customer/customer_auth_flow.dart';
import 'package:mnd_customer/features/home/customer_home_page.dart';
import 'package:mnd_theme/mnd_theme.dart';

/// Root widget for the customer app.
class MndCustomerApp extends StatefulWidget {
  const MndCustomerApp({super.key});

  @override
  State<MndCustomerApp> createState() => _MndCustomerAppState();
}

class _MndCustomerAppState extends State<MndCustomerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MND Customer App',
      debugShowCheckedModeBanner: false,
      theme: MndAppTheme.light,
      darkTheme: MndAppTheme.dark,
      themeMode: _themeMode,
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
      home: _AuthGate(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.themeMode, required this.onThemeModeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data != null) {
          return CustomerHomePage(
            user: snapshot.data!,
            themeMode: themeMode,
            onThemeModeChanged: onThemeModeChanged,
          );
        }

        return const CustomerAuthFlow();
      },
    );
  }
}
