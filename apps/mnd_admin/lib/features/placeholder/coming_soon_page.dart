import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

/// Placeholder for modules not built yet (Users, Shops, Orders, …).
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    super.key,
    required this.title,
    this.description,
  });

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final glass = mndGlassChromeEnabled;

    final inner = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.construction_outlined, size: 56, color: scheme.primary),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          description ??
              'This section will be connected to Firestore and business '
              'flows in a follow-up.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (glass) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: MndGlassPanel(
              borderRadius: BorderRadius.circular(20),
              blurSigma: 24,
              fillAlpha: 0.44,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: inner,
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: inner,
        ),
      ),
    );
  }
}
