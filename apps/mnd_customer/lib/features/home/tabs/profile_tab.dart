import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Profile + sign out (reference bottom-nav slot).
class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.user,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final User user;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final canPop = Navigator.of(context).canPop();

    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (canPop)
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    ),
                  if (canPop) const SizedBox(width: 8),
                  Text(
                    'Profile',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: cs.surfaceContainerLowest,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.person_rounded, color: cs.primary),
                  ),
                  title: const Text('Signed in'),
                  subtitle: Text(
                    user.phoneNumber ?? user.email ?? user.uid,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                elevation: 0,
                color: cs.surfaceContainerLowest,
                child: SwitchListTile.adaptive(
                  secondary: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: cs.primary,
                  ),
                  title: const Text('Dark mode'),
                  subtitle: const Text('Switch between light and dark theme'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (enabled) => onThemeModeChanged(
                    enabled ? ThemeMode.dark : ThemeMode.light,
                  ),
                ),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
