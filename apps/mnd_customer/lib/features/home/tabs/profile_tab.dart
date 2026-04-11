import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Profile + sign out (reference bottom-nav slot).
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
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
