import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

import '../../widgets/app_snackbar.dart';
import '../home/models/home_catalog_models.dart';
import '../home/widgets/home_product_card.dart';
import 'shop_catalog.dart';
import 'shop_menu_page.dart';

/// Food browse: search, categories, promo, nearby restaurants, popular picks.
class FoodPage extends StatefulWidget {
  const FoodPage({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  /// 0 = Food, 1 = Shop (top bar).
  int _topSegment = 0;

  int _categoryIndex = 0;

  static const List<String> _categories = [
    'All',
    'Pizza',
    'Sri Lankan',
    'Fast food',
    'Healthy',
  ];

  static const List<_RestaurantPreview> _nearby = [
    _RestaurantPreview(
      name: 'Colombo Kitchen',
      cuisine: 'Sri Lankan · Rice & curry',
      rating: '4.8',
      eta: '25–35 min',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
    ),
    _RestaurantPreview(
      name: 'Urban Slice',
      cuisine: 'Italian · Pizza',
      rating: '4.6',
      eta: '20–30 min',
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=80',
    ),
    _RestaurantPreview(
      name: 'Spice Route',
      cuisine: 'Asian · Noodles',
      rating: '4.7',
      eta: '18–28 min',
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
    ),
    _RestaurantPreview(
      name: 'Green Bowl',
      cuisine: 'Salads · Bowls',
      rating: '4.5',
      eta: '15–25 min',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final base = cs.surfaceContainerLowest;

    return Scaffold(
      backgroundColor: base,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  if (widget.showBackButton)
                    _RoundIconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icons.arrow_back_ios_new_rounded,
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                    )
                  else
                    const SizedBox(width: 44, height: 44),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(
                      child: _FoodShopSegmented(
                        selectedIndex: _topSegment,
                        onChanged: (i) => setState(() => _topSegment = i),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _RoundIconButton(
                    onPressed: () {
                      AppSnackBar.showInfo(
                        context,
                        message: 'Filters are coming soon.',
                        icon: Icons.tune_rounded,
                      );
                    },
                    icon: Icons.tune_rounded,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _topSegment == 0
                ? _buildFoodScrollView(context)
                : _buildShopScrollView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodScrollView(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'What would you like to eat today?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: MndBrandColors.navy,
                    height: 1.15,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fresh picks, top-rated places, and quick delivery near you.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _SearchField(
                  onTap: () {
                    AppSnackBar.showInfo(
                      context,
                      message: 'Search is coming soon.',
                      icon: Icons.search_rounded,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _CategoryRow(
                  labels: _categories,
                  selectedIndex: _categoryIndex,
                  onSelected: (i) => setState(() => _categoryIndex = i),
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  title: 'Near you',
                  actionLabel: 'Map',
                  onAction: () {
                    AppSnackBar.showInfo(
                      context,
                      message: 'Map view is coming soon.',
                      icon: Icons.map_outlined,
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _nearby.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                return SizedBox(
                  width: 280,
                  child: _RestaurantCard(restaurant: _nearby[i]),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: _SectionTitle(
              title: 'Popular picks',
              actionLabel: 'See all',
              onAction: () {
                AppSnackBar.showInfo(
                  context,
                  message: 'Full list is coming soon.',
                  icon: Icons.grid_view_rounded,
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                const gap = 14.0;
                final tileW = (w - gap) / 2;
                const aspect = 0.72;
                final tileH = tileW / aspect;

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: HomeMockCatalog.bestSellers
                      .map(
                        (p) => SizedBox(
                          width: tileW,
                          height: tileH,
                          child: HomeProductCard(product: p),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopScrollView(BuildContext context) {
    final theme = Theme.of(context);
    final shops = ShopMockCatalog.shops;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SearchField(
                  hint: 'Search shops or products',
                  onTap: () {
                    AppSnackBar.showInfo(
                      context,
                      message: 'Search is coming soon.',
                      icon: Icons.search_rounded,
                    );
                  },
                ),
                const SizedBox(height: 22),
                Text(
                  'Shops near you',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a shop to see products',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList.separated(
            itemCount: shops.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final shop = shops[index];
              return _ShopListCard(
                shop: shop,
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => ShopMenuPage(shop: shop),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// One row in the Shop tab list.
class _ShopListCard extends StatelessWidget {
  const _ShopListCard({required this.shop, required this.onTap});

  final ShopListing shop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 80,
                    height: 80,
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
                          size: 36,
                          color: cs.outline,
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
                        shop.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shop.tagline,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 2),
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
                Icon(Icons.chevron_right_rounded, color: cs.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodShopSegmented extends StatelessWidget {
  const _FoodShopSegmented({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  label: 'Food',
                  selected: selectedIndex == 0,
                  onTap: () => onChanged(0),
                ),
              ),
              Expanded(
                child: _SegmentButton(
                  label: 'Shop',
                  selected: selectedIndex == 1,
                  onTap: () => onChanged(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  final VoidCallback onPressed;
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
        onTap: onPressed,
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

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected ? MndBrandColors.navy : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: selected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantPreview {
  const _RestaurantPreview({
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.eta,
    required this.imageUrl,
  });

  final String name;
  final String cuisine;
  final String rating;
  final String eta;
  final String imageUrl;
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.onTap,
    this.hint = 'Search restaurants or dishes',
  });

  final VoidCallback onTap;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: MndBrandColors.blueMuted,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hint,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Material(
              color: selectedIndex == i
                  ? MndBrandColors.sky.withValues(alpha: 0.28)
                  : cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: () => onSelected(i),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selectedIndex == i
                          ? MndBrandColors.royal.withValues(alpha: 0.35)
                          : cs.outline.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selectedIndex == i
                          ? MndBrandColors.navy
                          : cs.onSurface,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: MndBrandColors.royal,
            ),
          ),
        ),
      ],
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant});

  final _RestaurantPreview restaurant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          onTap: () {
            AppSnackBar.showInfo(
              context,
              message: '${restaurant.name} details are coming soon.',
              icon: Icons.restaurant_menu_rounded,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Image.network(
                  restaurant.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return ColoredBox(
                      color: cs.surfaceContainerHighest,
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
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
                      Icons.restaurant_rounded,
                      size: 40,
                      color: cs.outline,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.cuisine,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            restaurant.rating,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: cs.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.eta,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
