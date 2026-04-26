import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

import '../../data/shops_repository.dart';
import 'shop_details_page.dart';
import 'shop_editor_dialog.dart';

/// Admin shops: Firestore `shops` — search, category chips, summary strip, list.
class ShopsPage extends StatefulWidget {
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  final _repo = ShopsRepository();
  final _search = TextEditingController();
  ShopCategory? _categoryFilter;

  late Stream<List<ShopRecord>> _shopsStream;

  @override
  void initState() {
    super.initState();
    _shopsStream = _repo.watchShops();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _retryStream() {
    setState(() => _shopsStream = _repo.watchShops());
  }

  Future<void> _onRefresh() async {
    _retryStream();
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _addShop() async {
    final draft = await showShopEditorDialog(context);
    if (draft == null || !mounted) return;
    try {
      await _repo.create(draft);
      if (mounted) _snack('Shop added.');
    } catch (e) {
      if (mounted) _snack('Could not add shop: $e');
    }
  }

  Future<void> _editShop(ShopRecord shop) async {
    final draft = await showShopEditorDialog(context, existing: shop);
    if (draft == null || !mounted) return;
    try {
      await _repo.update(shop.id, draft);
      if (mounted) _snack('Shop updated.');
    } catch (e) {
      if (mounted) _snack('Could not save: $e');
    }
  }

  Future<void> _confirmDelete(ShopRecord shop) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete shop?'),
        content: Text(
          'Remove "${shop.name}" from the directory? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _repo.delete(shop.id);
      if (mounted) _snack('Shop deleted.');
    } catch (e) {
      if (mounted) _snack('Could not delete: $e');
    }
  }

  Future<void> _setStatus(ShopRecord shop, ShopRecordStatus status) async {
    try {
      await _repo.setStatus(shop.id, status);
      if (mounted) {
        _snack(
          switch (status) {
            ShopRecordStatus.active => 'Shop approved / active.',
            ShopRecordStatus.suspended => 'Shop suspended.',
            ShopRecordStatus.pending => 'Status set to pending.',
          },
        );
      }
    } catch (e) {
      if (mounted) _snack('Could not update status: $e');
    }
  }

  List<ShopRecord> _filtered(List<ShopRecord> shops) {
    final q = _search.text.trim().toLowerCase();
    Iterable<ShopRecord> rows = shops;
    if (_categoryFilter != null) {
      rows = rows.where((s) => s.category == _categoryFilter);
    }
    if (q.isEmpty) return rows.toList();
    return rows
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.ownerName.toLowerCase().contains(q) ||
              s.area.toLowerCase().contains(q) ||
              s.phone.toLowerCase().contains(q) ||
              s.id.toLowerCase().contains(q) ||
              s.category.label.toLowerCase().contains(q),
        )
        .toList();
  }

  ({int total, int pending, int active, int suspended}) _counts(
    List<ShopRecord> shops,
  ) {
    var pending = 0;
    var active = 0;
    var suspended = 0;
    for (final s in shops) {
      switch (s.status) {
        case ShopRecordStatus.pending:
          pending++;
          break;
        case ShopRecordStatus.active:
          active++;
          break;
        case ShopRecordStatus.suspended:
          suspended++;
          break;
      }
    }
    return (
      total: shops.length,
      pending: pending,
      active: active,
      suspended: suspended,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final glass = mndGlassChromeEnabled;

    Widget cardShell({required Widget child, double radius = 18}) {
      if (glass) {
        return MndGlassPanel(
          borderRadius: BorderRadius.circular(radius),
          blurSigma: 22,
          fillAlpha: 0.42,
          child: child,
        );
      }
      return Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    }

    return StreamBuilder<List<ShopRecord>>(
      stream: _shopsStream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_outlined, size: 48, color: scheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load shops',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snap.error.toString(),
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _retryStream,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final shops = snap.data;
        if (shops == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final counts = _counts(shops);
        final filtered = _filtered(shops);

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shops',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${counts.total} in directory · ${filtered.length} shown',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _addShop,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Add shop'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search name, owner, phone, area, ID…',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: scheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: glass
                            ? scheme.surface.withValues(alpha: 0.35)
                            : scheme.surfaceContainerHighest
                                .withValues(alpha: 0.65),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Category',
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CategoryChipBar(
                      scheme: scheme,
                      selected: _categoryFilter,
                      onChanged: (c) => setState(() => _categoryFilter = c),
                    ),
                    const SizedBox(height: 22),
                    _SummaryStrip(
                      scheme: scheme,
                      counts: counts,
                      cardShell: cardShell,
                    ),
                    const SizedBox(height: 22),
                    if (shops.isEmpty)
                      _EmptyState(
                        scheme: scheme,
                        textTheme: textTheme,
                        onAdd: _addShop,
                      )
                    else if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No shops match your search or category.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < filtered.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _ShopCard(
                          scheme: scheme,
                          textTheme: textTheme,
                          glass: glass,
                          shop: filtered[i],
                          cardShell: cardShell,
                          onOpenDetails: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (ctx) => ShopDetailsPage(
                                  shopId: filtered[i].id,
                                ),
                              ),
                            );
                          },
                          onEdit: () => _editShop(filtered[i]),
                          onDelete: () => _confirmDelete(filtered[i]),
                          onApprove: filtered[i].status ==
                                  ShopRecordStatus.pending
                              ? () => _setStatus(
                                    filtered[i],
                                    ShopRecordStatus.active,
                                  )
                              : null,
                          onSuspend: filtered[i].status ==
                                  ShopRecordStatus.active
                              ? () => _setStatus(
                                    filtered[i],
                                    ShopRecordStatus.suspended,
                                  )
                              : null,
                          onReinstate: filtered[i].status ==
                                  ShopRecordStatus.suspended
                              ? () => _setStatus(
                                    filtered[i],
                                    ShopRecordStatus.active,
                                  )
                              : null,
                        ),
                      ],
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

class _CategoryChipBar extends StatelessWidget {
  const _CategoryChipBar({
    required this.scheme,
    required this.selected,
    required this.onChanged,
  });

  final ColorScheme scheme;
  final ShopCategory? selected;
  final ValueChanged<ShopCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selected == null,
              showCheckmark: false,
              onSelected: (_) => onChanged(null),
            ),
          ),
          for (final cat in ShopCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat.label),
                selected: selected == cat,
                showCheckmark: false,
                onSelected: (v) => onChanged(v ? cat : null),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.scheme,
    required this.counts,
    required this.cardShell,
  });

  final ColorScheme scheme;
  final ({int total, int pending, int active, int suspended}) counts;
  final Widget Function({required Widget child, double radius}) cardShell;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return cardShell(
      radius: 16,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                label: 'Total',
                value: '${counts.total}',
                valueStyle: t.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                scheme: scheme,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: scheme.outline.withValues(alpha: 0.22),
            ),
            Expanded(
              child: _StatCell(
                label: 'Pending',
                value: '${counts.pending}',
                valueStyle: t.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: MndPalette.warning,
                  letterSpacing: -0.3,
                ),
                scheme: scheme,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: scheme.outline.withValues(alpha: 0.22),
            ),
            Expanded(
              child: _StatCell(
                label: 'Active',
                value: '${counts.active}',
                valueStyle: t.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: MndPalette.positive,
                  letterSpacing: -0.3,
                ),
                scheme: scheme,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: scheme.outline.withValues(alpha: 0.22),
            ),
            Expanded(
              child: _StatCell(
                label: 'Suspended',
                value: '${counts.suspended}',
                valueStyle: t.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.error,
                  letterSpacing: -0.3,
                ),
                scheme: scheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.valueStyle,
    required this.scheme,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valueStyle?.copyWith(color: valueStyle?.color ?? scheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.scheme,
    required this.textTheme,
    required this.onAdd,
  });

  final ColorScheme scheme;
  final TextTheme textTheme;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 56,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No shops yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a shop to build your directory.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add first shop'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ShopMenuAction { edit, delete, approve, suspend, reinstate }

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.scheme,
    required this.textTheme,
    required this.glass,
    required this.shop,
    required this.cardShell,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onDelete,
    this.onApprove,
    this.onSuspend,
    this.onReinstate,
  });

  final ColorScheme scheme;
  final TextTheme textTheme;
  final bool glass;
  final ShopRecord shop;
  final Widget Function({required Widget child, double radius}) cardShell;
  final VoidCallback onOpenDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onSuspend;
  final VoidCallback? onReinstate;

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(shop.status, scheme);

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShopAvatar(scheme: scheme, name: shop.name),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              onTap: onOpenDetails,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusPill(
                          label: status.label,
                          background: status.background,
                          foreground: status.foreground,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DataLine(
                      icon: Icons.person_outline_rounded,
                      label: 'Owner',
                      value: shop.ownerName.isEmpty ? '—' : shop.ownerName,
                      scheme: scheme,
                      textTheme: textTheme,
                    ),
                    _DataLine(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: shop.phone.isEmpty ? '—' : shop.phone,
                      scheme: scheme,
                      textTheme: textTheme,
                    ),
                    _DataLine(
                      icon: Icons.place_outlined,
                      label: 'Area',
                      value: shop.area.isEmpty ? '—' : shop.area,
                      scheme: scheme,
                      textTheme: textTheme,
                    ),
                    _DataLine(
                      icon: Icons.category_outlined,
                      label: 'Type',
                      value: shop.category.label,
                      scheme: scheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID ${shop.id}',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: scheme.primary),
              ),
              PopupMenuButton<_ShopMenuAction>(
                tooltip: 'More',
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: scheme.onSurfaceVariant,
                ),
                onSelected: (action) {
                  switch (action) {
                    case _ShopMenuAction.edit:
                      onEdit();
                    case _ShopMenuAction.delete:
                      onDelete();
                    case _ShopMenuAction.approve:
                      onApprove?.call();
                    case _ShopMenuAction.suspend:
                      onSuspend?.call();
                    case _ShopMenuAction.reinstate:
                      onReinstate?.call();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _ShopMenuAction.edit,
                    child: Text('Edit shop'),
                  ),
                  if (onApprove != null)
                    const PopupMenuItem(
                      value: _ShopMenuAction.approve,
                      child: Text('Approve'),
                    ),
                  if (onSuspend != null)
                    PopupMenuItem(
                      value: _ShopMenuAction.suspend,
                      child: Text(
                        'Suspend',
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  if (onReinstate != null)
                    const PopupMenuItem(
                      value: _ShopMenuAction.reinstate,
                      child: Text('Reinstate'),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _ShopMenuAction.delete,
                    child: Text(
                      'Delete',
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return cardShell(
      radius: 18,
      child: Material(
        color: Colors.transparent,
        child: body,
      ),
    );
  }
}

class _ShopAvatar extends StatelessWidget {
  const _ShopAvatar({required this.scheme, required this.name});

  final ColorScheme scheme;
  final String name;

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 26,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      child: Text(
        letter,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
      ),
    );
  }
}

class _DataLine extends StatelessWidget {
  const _DataLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Icon(
              icon,
              size: 18,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

({String label, Color background, Color foreground}) _statusPresentation(
  ShopRecordStatus s,
  ColorScheme scheme,
) {
  switch (s) {
    case ShopRecordStatus.pending:
      return (
        label: 'Pending',
        background: MndPalette.warning.withValues(alpha: 0.2),
        foreground: scheme.brightness == Brightness.dark
            ? const Color(0xFFFBBF24)
            : const Color(0xFFB45309),
      );
    case ShopRecordStatus.active:
      return (
        label: 'Active',
        background: MndPalette.positive.withValues(alpha: 0.18),
        foreground: scheme.brightness == Brightness.dark
            ? const Color(0xFF6EE7B7)
            : MndPalette.positive,
      );
    case ShopRecordStatus.suspended:
      return (
        label: 'Suspended',
        background: scheme.errorContainer.withValues(alpha: 0.85),
        foreground: scheme.onErrorContainer,
      );
  }
}
