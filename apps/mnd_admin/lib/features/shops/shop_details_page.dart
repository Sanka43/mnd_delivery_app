import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/shop_items_repository.dart';
import '../../data/shops_repository.dart';
import 'shop_editor_dialog.dart';
import 'shop_item_editor_dialog.dart';

enum _ItemMenuAction { edit, delete }

/// Full shop profile, call action, and admin menu items (`shops/.../items`).
class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key, required this.shopId});

  final String shopId;

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _shopsRepo = ShopsRepository();
  final _itemsRepo = ShopItemsRepository();

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    final ok = await canLaunchUrl(uri);
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open phone dialer.')),
        );
      }
      return;
    }
    await launchUrl(uri);
  }

  Future<void> _editShop(ShopRecord shop) async {
    final draft = await showShopEditorDialog(context, existing: shop);
    if (draft == null || !mounted) return;
    try {
      await _shopsRepo.update(widget.shopId, draft);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  Future<void> _addItem() async {
    final draft = await showShopItemEditorDialog(context);
    if (draft == null || !mounted) return;
    try {
      final imageFailed = await _itemsRepo.create(widget.shopId, draft);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              imageFailed
                  ? 'Item added (image upload failed — add a photo later).'
                  : 'Item added.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add item: $e')),
        );
      }
    }
  }

  Future<void> _editItem(ShopItemRecord item) async {
    final draft = await showShopItemEditorDialog(context, existing: item);
    if (draft == null || !mounted) return;
    try {
      await _itemsRepo.update(
        widget.shopId,
        item.id,
        draft,
        previousImageUrl: item.imageUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    }
  }

  Future<void> _deleteItem(ShopItemRecord item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Remove "${item.name}" from this shop?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _itemsRepo.delete(
        widget.shopId,
        item.id,
        imageUrl: item.imageUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete: $e')),
        );
      }
    }
  }

  Future<void> _setItemAvailable(ShopItemRecord item, bool available) async {
    try {
      await _itemsRepo.setAvailable(widget.shopId, item.id, available);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update availability: $e')),
        );
      }
    }
  }

  Widget _cardShell({
    required ColorScheme scheme,
    required bool glass,
    required Widget child,
    double radius = 18,
  }) {
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final glass = mndGlassChromeEnabled;

    return StreamBuilder<ShopRecord?>(
      stream: _shopsRepo.watchShop(widget.shopId),
      builder: (context, shopSnap) {
        if (shopSnap.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shop')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 48, color: scheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load shop',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      shopSnap.error.toString(),
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final shop = shopSnap.data;
        final loadingShop =
            shopSnap.connectionState == ConnectionState.waiting && shop == null;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              shop?.name ?? 'Shop details',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              if (shop != null)
                IconButton(
                  tooltip: 'Edit shop',
                  onPressed: () => _editShop(shop),
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          body: loadingShop && shop == null
              ? const Center(child: CircularProgressIndicator())
              : shop == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 56,
                              color: scheme.onSurfaceVariant.withValues(
                                alpha: 0.45,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Shop not found',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This shop was removed or you do not have access.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _cardShell(
                                scheme: scheme,
                                glass: glass,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    18,
                                    18,
                                    16,
                                  ),
                                  child: _ShopProfileHeader(
                                    scheme: scheme,
                                    textTheme: textTheme,
                                    shop: shop,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _cardShell(
                                scheme: scheme,
                                glass: glass,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    16,
                                    18,
                                    18,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Contact & details',
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      _ProfileDataLine(
                                        scheme: scheme,
                                        textTheme: textTheme,
                                        icon: Icons.person_outline_rounded,
                                        label: 'Owner',
                                        value: shop.ownerName.isEmpty
                                            ? '—'
                                            : shop.ownerName,
                                      ),
                                      _ProfileDataLine(
                                        scheme: scheme,
                                        textTheme: textTheme,
                                        icon: Icons.phone_outlined,
                                        label: 'Phone',
                                        value: shop.phone.isEmpty
                                            ? '—'
                                            : shop.phone,
                                      ),
                                      _ProfileDataLine(
                                        scheme: scheme,
                                        textTheme: textTheme,
                                        icon: Icons.place_outlined,
                                        label: 'Area',
                                        value: shop.area.isEmpty
                                            ? '—'
                                            : shop.area,
                                      ),
                                      _ProfileDataLine(
                                        scheme: scheme,
                                        textTheme: textTheme,
                                        icon: Icons.category_outlined,
                                        label: 'Type',
                                        value: shop.category.label,
                                      ),
                                      if (shop.createdAt != null)
                                        _ProfileDataLine(
                                          scheme: scheme,
                                          textTheme: textTheme,
                                          icon: Icons.event_outlined,
                                          label: 'Registered',
                                          value:
                                              '${shop.createdAt!.day}/${shop.createdAt!.month}/${shop.createdAt!.year}',
                                        ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Firestore ID ${shop.id}',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: scheme.onSurfaceVariant
                                              .withValues(alpha: 0.85),
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      FilledButton.icon(
                                        onPressed: shop.phone.trim().isEmpty
                                            ? null
                                            : () => _call(shop.phone),
                                        icon: const Icon(Icons.call_rounded),
                                        label: const Text('Call shop'),
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              StreamBuilder<List<ShopItemRecord>>(
                                stream: _itemsRepo.watchItems(widget.shopId),
                                builder: (context, itemSnap) {
                                  final n = itemSnap.data?.length;
                                  final countLine = itemSnap.hasError
                                      ? 'Could not load items'
                                      : n == null
                                          ? 'Loading…'
                                          : n == 0
                                              ? 'No items yet'
                                              : '$n item${n == 1 ? '' : 's'}';

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Menu items',
                                                  style: textTheme.titleLarge
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  countLine,
                                                  style: textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: itemSnap.hasError
                                                        ? scheme.error
                                                        : scheme
                                                            .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          FilledButton.tonalIcon(
                                            onPressed: _addItem,
                                            icon: const Icon(
                                              Icons.add_rounded,
                                              size: 22,
                                            ),
                                            label: const Text('Add item'),
                                            style: FilledButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      if (itemSnap.hasError)
                                        _cardShell(
                                          scheme: scheme,
                                          glass: glass,
                                          radius: 16,
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.error_outline_rounded,
                                                  color: scheme.error,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    itemSnap.error.toString(),
                                                    style: textTheme.bodyMedium
                                                        ?.copyWith(
                                                      color: scheme.error,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else if (itemSnap.data == null)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 40,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      else if (itemSnap.data!.isEmpty)
                                        _cardShell(
                                          scheme: scheme,
                                          glass: glass,
                                          radius: 16,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 36,
                                              horizontal: 24,
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .restaurant_menu_outlined,
                                                  size: 48,
                                                  color: scheme
                                                      .onSurfaceVariant
                                                      .withValues(alpha: 0.45),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'No menu items',
                                                  style: textTheme.titleSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Add dishes or products '
                                                  'customers can order from '
                                                  'this shop.',
                                                  textAlign: TextAlign.center,
                                                  style: textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: scheme
                                                        .onSurfaceVariant,
                                                    height: 1.35,
                                                  ),
                                                ),
                                                const SizedBox(height: 18),
                                                FilledButton.icon(
                                                  onPressed: _addItem,
                                                  icon: const Icon(
                                                    Icons.add_rounded,
                                                  ),
                                                  label: const Text(
                                                    'Add first item',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        Column(
                                          children: [
                                            for (var i = 0;
                                                i < itemSnap.data!.length;
                                                i++)
                                              Builder(
                                                builder: (context) {
                                                  final it = itemSnap.data![i];
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom: i <
                                                              itemSnap
                                                                      .data!
                                                                      .length -
                                                                  1
                                                          ? 12
                                                          : 0,
                                                    ),
                                                    child: _MenuItemCard(
                                                      scheme: scheme,
                                                      textTheme: textTheme,
                                                      glass: glass,
                                                      item: it,
                                                      cardShell: _cardShell,
                                                      onEdit: () =>
                                                          _editItem(it),
                                                      onDelete: () =>
                                                          _deleteItem(it),
                                                      onSetAvailable: (av) =>
                                                          _setItemAvailable(
                                                        it,
                                                        av,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                    ],
                                  );
                                },
                              ),
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

class _ShopProfileHeader extends StatelessWidget {
  const _ShopProfileHeader({
    required this.scheme,
    required this.textTheme,
    required this.shop,
  });

  final ColorScheme scheme;
  final TextTheme textTheme;
  final ShopRecord shop;

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(shop.status, scheme);
    final letter = shop.name.isNotEmpty ? shop.name[0].toUpperCase() : '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Text(
                letter,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _StatusPill(
                        label: status.label,
                        background: status.background,
                        foreground: status.foreground,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest
                              .withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          shop.category.label,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (shop.area.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            shop.area,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileDataLine extends StatelessWidget {
  const _ProfileDataLine({
    required this.scheme,
    required this.textTheme,
    required this.icon,
    required this.label,
    required this.value,
  });

  final ColorScheme scheme;
  final TextTheme textTheme;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            width: 88,
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
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.scheme,
    required this.textTheme,
    required this.glass,
    required this.item,
    required this.cardShell,
    required this.onEdit,
    required this.onDelete,
    required this.onSetAvailable,
  });

  final ColorScheme scheme;
  final TextTheme textTheme;
  final bool glass;
  final ShopItemRecord item;
  final Widget Function({
    required ColorScheme scheme,
    required bool glass,
    required Widget child,
    double radius,
  }) cardShell;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function(bool available) onSetAvailable;

  @override
  Widget build(BuildContext context) {
    final priceText = item.price == item.price.roundToDouble()
        ? '${item.price.round()} LKR'
        : '${item.price} LKR';

    final thumbUrl = item.imageUrl;
    final thumb = thumbUrl != null && thumbUrl.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 68,
              height: 68,
              child: Image.network(
                thumbUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        : Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.restaurant_menu_outlined,
              color: scheme.onSurfaceVariant,
              size: 30,
            ),
          );

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: item.available ? 1 : 0.88,
            child: thumb,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: item.available
                        ? null
                        : scheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!item.available)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer
                              .withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Unavailable',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onErrorContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priceText,
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Available for orders',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: item.available,
                      onChanged: (v) => onSetAvailable(v),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'ID ${item.id}',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit item',
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: scheme.primary),
              ),
              PopupMenuButton<_ItemMenuAction>(
                tooltip: 'More',
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: scheme.onSurfaceVariant,
                ),
                onSelected: (action) {
                  switch (action) {
                    case _ItemMenuAction.edit:
                      onEdit();
                    case _ItemMenuAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _ItemMenuAction.edit,
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: _ItemMenuAction.delete,
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
      scheme: scheme,
      glass: glass,
      radius: 16,
      child: Material(color: Colors.transparent, child: body),
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
