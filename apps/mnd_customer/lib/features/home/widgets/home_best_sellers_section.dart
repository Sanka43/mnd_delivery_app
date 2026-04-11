import 'package:flutter/material.dart';

import '../models/home_catalog_models.dart';
import 'home_product_card.dart';

/// Section title + 2-column grid of products.
class HomeBestSellersSection extends StatelessWidget {
  const HomeBestSellersSection({
    super.key,
    required this.products,
  });

  final List<HomeProduct> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Best Sellers',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('See all — coming soon')),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              const gap = 14.0;
              final tileW = (w - gap) / 2;
              const aspect = 0.72;
              final tileH = tileW / aspect;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: products
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
        ],
      ),
    );
  }
}
