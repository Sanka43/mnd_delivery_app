import 'package:flutter/material.dart';
import 'package:mnd_core/mnd_core.dart';

import 'models/home_catalog_models.dart';
import 'widgets/active_order_card.dart';
import 'widgets/home_best_sellers_section.dart';
import 'widgets/home_services_strip.dart';
import 'widgets/home_top_header.dart';

/// Scrollable home content matching the reference layout.
class HomeFeedView extends StatelessWidget {
  const HomeFeedView({
    super.key,
    this.activeOrderStatus,
  });

  final OrderStatus? activeOrderStatus;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return ColoredBox(
      color: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: ColoredBox(
              color: surface,
              child: const HomeTopHeader(),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      HomeServicesStrip(
                        services: HomeMockCatalog.services,
                      ),
                      if (activeOrderStatus != null) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ActiveOrderCard(activeStatus: activeOrderStatus),
                        ),
                      ],
                      const SizedBox(height: 26),
                      HomeBestSellersSection(
                        products: HomeMockCatalog.bestSellers,
                      ),
                      const SizedBox(height: 100),
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
