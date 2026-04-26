import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

import '../../widgets/app_snackbar.dart';
import 'shop_catalog.dart';

/// Menu / product list for one shop.
class ShopMenuPage extends StatelessWidget {
  const ShopMenuPage({super.key, required this.shop});

  final ShopListing shop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final base = cs.surfaceContainerLowest;
    final items = ShopMockCatalog.menuFor(shop.id);

    return Scaffold(
      backgroundColor: base,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: base,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: _RoundIconButton(
                onTap: () => Navigator.of(context).maybePop(),
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
            ),
            title: Text(
              shop.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: MndBrandColors.navy,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _RoundIconButton(
                  onTap: () {
                    AppSnackBar.showInfo(
                      context,
                      message: 'Search is coming soon.',
                      icon: Icons.search_rounded,
                    );
                  },
                  icon: Icons.search_rounded,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: Image.network(
                          shop.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return ColoredBox(
                              color: cs.surfaceContainerHighest,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => ColoredBox(
                            color: cs.surfaceContainerHighest,
                            child: Icon(
                              Icons.storefront_rounded,
                              color: cs.outline,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.tagline,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                shop.rating,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: cs.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                shop.eta,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Popular items from ${shop.name}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: MndBrandColors.navy,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ShopMenuItemTile(item: items[index]);
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _ShopMenuItemTile extends StatelessWidget {
  const _ShopMenuItemTile({required this.item});

  final ShopMenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return ColoredBox(
                          color: cs.surfaceContainerHighest,
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: cs.surfaceContainerHighest,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: cs.outline,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.detail != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.detail!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        item.priceLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: MndBrandColors.royal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: MndBrandColors.navy,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      AppSnackBar.showSuccess(
                        context,
                        message: 'Added to cart: ${item.name}',
                        icon: Icons.shopping_bag_rounded,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.onTap,
    required this.icon,
    this.tooltip,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerLowest,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: tooltip == null
            ? SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, size: 22, color: MndBrandColors.navy),
              )
            : Tooltip(
                message: tooltip!,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(icon, size: 22, color: MndBrandColors.navy),
                ),
              ),
      ),
    );
  }
}
