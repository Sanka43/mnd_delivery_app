import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnd_core/mnd_core.dart';

import '../../widgets/app_snackbar.dart';
import 'models/home_catalog_models.dart';
import 'widgets/active_order_card.dart';
import 'widgets/home_best_sellers_section.dart';
import 'widgets/home_category_strip.dart';
import 'widgets/home_near_me_shops_section.dart';
import 'widgets/home_promo_banner.dart';
import 'widgets/home_quick_actions_bar.dart';
import 'widgets/home_top_header.dart';

/// Scrollable home — reference layout (header with search, headline, promo, categories, popular).
class HomeFeedView extends StatefulWidget {
  const HomeFeedView({
    super.key,
    required this.user,
    this.activeOrderStatus,
    required this.onOpenFood,
    required this.onOpenProfile,
  });

  final User user;
  final OrderStatus? activeOrderStatus;
  final VoidCallback onOpenFood;
  final VoidCallback onOpenProfile;

  @override
  State<HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends State<HomeFeedView> {
  bool _searchOverlayOpen = false;

  void _openFood() {
    widget.onOpenFood();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final base = isDark ? cs.surfaceContainerLowest : const Color(0xFFF5F7FD);

    return ColoredBox(
      color: base,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: ColoredBox(
              color: base,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HomeTopHeader(
                    user: widget.user,
                    onOpenProfile: widget.onOpenProfile,
                    onSearchOverlayChanged: (open) {
                      setState(() => _searchOverlayOpen = open);
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              physics: _searchOverlayOpen
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),
                      HomeQuickActionsBar(
                        actions: [
                          HomeQuickActionData(
                            label: 'Food',
                            icon: Icons.restaurant_rounded,
                            iconAssetPath: 'assets/icons/food_burger.png',
                            onPressed: _openFood,
                          ),
                          HomeQuickActionData(
                            label: 'Market',
                            icon: Icons.storefront_rounded,
                            iconAssetPath: 'assets/icons/market_store.png',
                            onPressed: () {
                              AppSnackBar.showInfo(
                                context,
                                message: 'Market is coming soon.',
                                icon: Icons.storefront_rounded,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      HomeNearMeShopsSection(
                        shops: HomeMockCatalog.nearMeShops,
                        onShopTap: (_) => _openFood(),
                      ),
                      const SizedBox(height: 18),
                      HomePopularFoodSection(
                        products: HomeMockCatalog.bestSellers,
                      ),
                      const SizedBox(height: 14),
                      HomePromoBanner(onOrderNow: _openFood),
                      const SizedBox(height: 18),
                      HomeCategoryStrip(
                        categories: HomeMockCatalog.categories,
                        onSelected: (_) {
                          AppSnackBar.showInfo(
                            context,
                            message: 'Category list is coming soon.',
                            icon: Icons.category_rounded,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (widget.activeOrderStatus != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ActiveOrderCard(
                            activeStatus: widget.activeOrderStatus,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
