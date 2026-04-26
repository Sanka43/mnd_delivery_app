import 'package:flutter/material.dart';

import '../../../widgets/app_snackbar.dart';
import '../models/home_catalog_models.dart';
import 'home_popular_food_card.dart';

/// "Popular Food" horizontal list (reference layout).
class HomePopularFoodSection extends StatelessWidget {
  const HomePopularFoodSection({super.key, required this.products});

  final List<HomeProduct> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Special',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  AppSnackBar.showInfo(
                    context,
                    message: 'Full list is coming soon.',
                    icon: Icons.grid_view_rounded,
                  );
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: products.length.clamp(0, 4),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              return SizedBox(
                width: 178,
                child: HomePopularFoodCard(product: products[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}
