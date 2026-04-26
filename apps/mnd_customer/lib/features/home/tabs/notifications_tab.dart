import 'package:flutter/material.dart';

class _MockNotification {
  const _MockNotification({
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.icon,
  });

  final String title;
  final String body;
  final String timeLabel;
  final IconData icon;
}

/// Bottom-nav Notifications slot — scrollable list (mock data until backend exists).
class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  static const _items = <_MockNotification>[
    _MockNotification(
      title: 'Order confirmed',
      body: 'Your order #1042 is being prepared. We will notify you when it is on the way.',
      timeLabel: '2h ago',
      icon: Icons.check_circle_outline_rounded,
    ),
    _MockNotification(
      title: 'Weekend promo',
      body: 'Get 15% off selected restaurants this weekend. Tap Food to browse.',
      timeLabel: 'Yesterday',
      icon: Icons.local_offer_rounded,
    ),
    _MockNotification(
      title: 'Delivery update',
      body: 'Your rider is 5 minutes away. Please keep your phone nearby.',
      timeLabel: '3d ago',
      icon: Icons.delivery_dining_rounded,
    ),
    _MockNotification(
      title: 'Profile reminder',
      body: 'Complete your delivery address in Profile for faster checkout.',
      timeLabel: '1w ago',
      icon: Icons.home_work_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Notifications',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final n = _items[index];
                  return Card(
                    elevation: 0,
                    color: cs.surfaceContainerLowest,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: cs.primaryContainer,
                        child: Icon(n.icon, color: cs.primary, size: 22),
                      ),
                      title: Text(
                        n.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          n.body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      trailing: Text(
                        n.timeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
