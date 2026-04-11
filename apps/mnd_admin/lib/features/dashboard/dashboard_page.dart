import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mnd_theme/mnd_theme.dart';

import '../../data/dashboard_repository.dart';

String _fmtInt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _fmtLkr(num n) => '${_fmtInt(n.round())} LKR';

final RegExp _dashboardUrlRx = RegExp(r'https://[^\s)\]]+');

/// Admin home: wallet-style layout (hero summary, quick links, activity).
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.onOpenSection});

  /// Shell navigation: indices match [AdminShellPage] `_items` order.
  final ValueChanged<int>? onOpenSection;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repo = DashboardRepository();
  Future<DashboardStats>? _future;
  bool _revenueVisible = true;

  @override
  void initState() {
    super.initState();
    _future = _repo.loadStats();
  }

  Future<void> _reload() async {
    setState(() => _future = _repo.loadStats());
    await _future;
  }

  void _go(int shellIndex) {
    widget.onOpenSection?.call(shellIndex);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<DashboardStats>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snap.data!;

        return RefreshIndicator(
          onRefresh: _reload,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (stats.hasWarnings) ...[
                      const SizedBox(height: 8),
                      _WarningBanner(
                        scheme: scheme,
                        warnings: stats.warnings.toSet().toList(),
                        urlRx: _dashboardUrlRx,
                      ),
                    ],
                    SizedBox(height: stats.hasWarnings ? 20 : 4),
                    _HeroSummaryCard(
                      scheme: scheme,
                      stats: stats,
                      revenueVisible: _revenueVisible,
                      onToggleRevenue: () =>
                          setState(() => _revenueVisible = !_revenueVisible),
                      onQuickAction: _go,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Quick links',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 0),
                    _QuickLinksGrid(
                      scheme: scheme,
                      onOpenSection: _go,
                      onRefresh: _reload,
                    ),
                    const SizedBox(height: 0),
                    Row(
                      children: [
                        Text(
                          'Recent activity',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _go(6),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ActivitySection(
                      scheme: scheme,
                      stats: stats,
                      revenueVisible: _revenueVisible,
                    ),
                    const SizedBox(height: 24),
                    _OrdersTrendCard(scheme: scheme),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({
    required this.scheme,
    required this.stats,
    required this.revenueVisible,
    required this.onToggleRevenue,
    required this.onQuickAction,
  });

  final ColorScheme scheme;
  final DashboardStats stats;
  final bool revenueVisible;
  final VoidCallback onToggleRevenue;
  final ValueChanged<int> onQuickAction;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        scheme.primary,
        Color.lerp(scheme.primary, scheme.tertiary, 0.45)!,
        scheme.tertiary,
      ],
    );

    final revText = revenueVisible
        ? 'Rs. ${_fmtInt(stats.revenueDeliveredToday.round())}'
        : '••••••';

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: scheme.onPrimary.withValues(alpha: 0.9),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delivered revenue (today)',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () {},
                    tooltip: 'Summary',
                    icon: Icon(
                      Icons.qr_code_2_rounded,
                      color: scheme.onPrimary.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      revText,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleRevenue,
                    tooltip: revenueVisible ? 'Hide amount' : 'Show amount',
                    icon: Icon(
                      revenueVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: scheme.onPrimary.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  final actions = <Widget>[
                    _HeroAction(
                      scheme: scheme,
                      icon: Icons.receipt_long_rounded,
                      label: 'Orders',
                      onTap: () => onQuickAction(4),
                    ),
                    _HeroAction(
                      scheme: scheme,
                      icon: Icons.payments_rounded,
                      label: 'Revenue',
                      onTap: () => onQuickAction(5),
                    ),
                    _HeroAction(
                      scheme: scheme,
                      icon: Icons.pedal_bike_rounded,
                      label: 'Riders',
                      onTap: () => onQuickAction(3),
                    ),
                    _HeroAction(
                      scheme: scheme,
                      icon: Icons.hourglass_top_rounded,
                      label: 'Pending',
                      onTap: () => onQuickAction(4),
                    ),
                    _HeroAction(
                      scheme: scheme,
                      icon: Icons.history_rounded,
                      label: 'Reports',
                      onTap: () => onQuickAction(6),
                    ),
                  ];
                  if (c.maxWidth >= 520) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 4),
                          Expanded(child: actions[i]),
                        ],
                      ],
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          SizedBox(width: 72, child: actions[i]),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.scheme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final ColorScheme scheme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.onPrimary.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: scheme.onPrimary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLinksGrid extends StatelessWidget {
  const _QuickLinksGrid({
    required this.scheme,
    required this.onOpenSection,
    required this.onRefresh,
  });

  final ColorScheme scheme;
  final ValueChanged<int> onOpenSection;
  final Future<void> Function() onRefresh;

  List<
      ({
        IconData icon,
        String label,
        int? sectionIndex,
        bool refresh,
      })> _items() => [
        (
          icon: Icons.home_rounded,
          label: 'Overview',
          sectionIndex: null,
          refresh: true,
        ),
        (
          icon: Icons.people_rounded,
          label: 'Users',
          sectionIndex: 1,
          refresh: false,
        ),
        (
          icon: Icons.storefront_rounded,
          label: 'Shops',
          sectionIndex: 2,
          refresh: false,
        ),
        (
          icon: Icons.pedal_bike_rounded,
          label: 'Riders',
          sectionIndex: 3,
          refresh: false,
        ),
        (
          icon: Icons.list_alt_rounded,
          label: 'Orders',
          sectionIndex: 4,
          refresh: false,
        ),
        (
          icon: Icons.account_balance_wallet_rounded,
          label: 'Payments',
          sectionIndex: 5,
          refresh: false,
        ),
        (
          icon: Icons.analytics_rounded,
          label: 'Reports',
          sectionIndex: 6,
          refresh: false,
        ),
        (
          icon: Icons.tune_rounded,
          label: 'Settings',
          sectionIndex: 7,
          refresh: false,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final items = _items();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return _QuickLinkTile(
          scheme: scheme,
          icon: item.icon,
          label: item.label,
          onTap: () async {
            if (item.refresh) {
              await onRefresh();
              return;
            }
            if (item.sectionIndex != null) {
              onOpenSection(item.sectionIndex!);
            }
          },
        );
      },
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  const _QuickLinkTile({
    required this.scheme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final ColorScheme scheme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const circle = 58.0;
    final isDark = scheme.brightness == Brightness.dark;
    final circleFill = isDark
        ? scheme.surfaceContainerHigh
        : scheme.surfaceContainerLow;
    final iconColor = isDark
        ? scheme.onSurface.withValues(alpha: 0.92)
        : const Color(0xFF1C1C1E);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: scheme.onSurface.withValues(alpha: 0.08),
        highlightColor: scheme.onSurface.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: circle,
                height: circle,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleFill,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 27),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 13,
                      height: 1.22,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.scheme,
    required this.stats,
    required this.revenueVisible,
  });

  final ColorScheme scheme;
  final DashboardStats stats;
  final bool revenueVisible;

  @override
  Widget build(BuildContext context) {
    final rows = <_ActivityRowData>[
      _ActivityRowData(
        avatar: Icons.shopping_bag_outlined,
        title: 'Orders today',
        subtitle: 'New orders placed',
        amount: '+${_fmtInt(stats.ordersToday)}',
        amountColor: MndPalette.positive,
        meta: 'Today',
      ),
      _ActivityRowData(
        avatar: Icons.pending_actions_outlined,
        title: 'Pending orders',
        subtitle: 'Awaiting shop / assignment',
        amount: _fmtInt(stats.pendingOrders),
        amountColor: MndPalette.warning,
        meta: 'Live',
      ),
      _ActivityRowData(
        avatar: Icons.payments_outlined,
        title: 'Delivered revenue',
        subtitle: 'Today (completed)',
        amount: revenueVisible
            ? '+${_fmtLkr(stats.revenueDeliveredToday)}'
            : '+•••••',
        amountColor: MndPalette.positive,
        meta: 'Today',
      ),
      _ActivityRowData(
        avatar: Icons.groups_outlined,
        title: 'Registered riders',
        subtitle: 'Fleet size',
        amount: '+${_fmtInt(stats.ridersRegistered)}',
        amountColor: scheme.primary,
        meta: 'Total',
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _ActivityRow(scheme: scheme, data: rows[i]),
        ],
      ],
    );
  }
}

class _ActivityRowData {
  const _ActivityRowData({
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.meta,
  });

  final IconData avatar;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final String meta;
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.scheme, required this.data});

  final ColorScheme scheme;
  final _ActivityRowData data;

  @override
  Widget build(BuildContext context) {
    final glassChrome = mndGlassChromeEnabled;
    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: scheme.primaryContainer.withValues(alpha: 0.65),
            child: Icon(data.avatar, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.amount,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: data.amountColor,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                data.meta,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );

    if (glassChrome) {
      return MndGlassPanel(
        borderRadius: BorderRadius.circular(18),
        blurSigma: 22,
        fillAlpha: 0.4,
        child: inner,
      );
    }

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 0,
      shadowColor: scheme.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: inner,
    );
  }
}

class _OrdersTrendCard extends StatelessWidget {
  const _OrdersTrendCard({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final glassChrome = mndGlassChromeEnabled;
    final inner = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders trend',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Daily or weekly charts can plug in here (reports module).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          _PlaceholderBars(color: scheme.primary),
        ],
      ),
    );

    if (glassChrome) {
      return MndGlassPanel(
        borderRadius: BorderRadius.circular(20),
        blurSigma: 24,
        fillAlpha: 0.44,
        child: inner,
      );
    }
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      child: inner,
    );
  }
}

class _PlaceholderBars extends StatelessWidget {
  const _PlaceholderBars({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final heights = <double>[32, 48, 40, 56, 44, 64, 52];
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heights.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: heights[i],
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2 + (i % 3) * 0.08),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({
    required this.scheme,
    required this.warnings,
    required this.urlRx,
  });

  final ColorScheme scheme;
  final List<String> warnings;
  final RegExp urlRx;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: scheme.onErrorContainer, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Some metrics could not be loaded',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final w in warnings) ...[
              _WarningBody(text: w, urlRx: urlRx, scheme: scheme),
              if (w != warnings.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _WarningBody extends StatelessWidget {
  const _WarningBody({
    required this.text,
    required this.urlRx,
    required this.scheme,
  });

  final String text;
  final RegExp urlRx;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final match = urlRx.firstMatch(text);
    if (match == null) {
      return SelectableText(
        text,
        style: TextStyle(fontSize: 12, color: scheme.onErrorContainer),
      );
    }
    final url = match.group(0)!;
    final before = text.substring(0, match.start);
    final after = text.substring(match.end);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (before.trim().isNotEmpty)
          SelectableText(
            before.trim(),
            style: TextStyle(fontSize: 12, color: scheme.onErrorContainer),
          ),
        const SizedBox(height: 6),
        SelectableText(
          url,
          style: TextStyle(
            fontSize: 12,
            color: scheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 6),
        FilledButton.tonal(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Index link copied to clipboard')),
            );
          },
          child: const Text('Copy Firebase index link'),
        ),
        if (after.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          SelectableText(
            after.trim(),
            style: TextStyle(fontSize: 12, color: scheme.onErrorContainer),
          ),
        ],
      ],
    );
  }
}
