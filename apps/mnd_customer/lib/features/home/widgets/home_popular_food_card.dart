import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

import '../../../widgets/app_snackbar.dart';
import '../models/home_catalog_models.dart';

/// Tall card for horizontal "Popular food" row (reference layout).
class HomePopularFoodCard extends StatelessWidget {
  const HomePopularFoodCard({super.key, required this.product});

  final HomeProduct product;

  /// Soft rounded panel behind title/price (fixed width, centered).
  static const double basePanelWidth = 160;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final panelColor = isDark
        ? cs.surfaceContainerHigh
        : Color.lerp(
            Colors.white,
            MndBrandColors.powder,
            0.72,
          )!;
    const imageSize = 126.0;
    const cardRadius = 22.0;
    const cardTopInset = 66.0;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: basePanelWidth,
                child: Container(
                  margin: const EdgeInsets.only(top: cardTopInset),
                  padding: const EdgeInsets.fromLTRB(14, 68, 14, 12),
                  decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: BorderRadius.circular(cardRadius),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: MndBrandColors.navy,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.priceLabel,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: MndBrandColors.royal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.prepTimeLabel} • ${product.caloriesLabel}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MndBrandColors.blueMuted,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.primary, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: panelColor,
                    child: Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: panelColor,
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: 52,
                    color: MndBrandColors.blueMuted,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 66,
              right: 16,
              child: Material(
                color: cs.surface,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    AppSnackBar.showSuccess(
                      context,
                      message: 'Added to cart: ${product.name}',
                      icon: Icons.shopping_bag_rounded,
                    );
                  },
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: Icon(Icons.add, color: cs.onSurface, size: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
