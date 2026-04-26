import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

import '../models/home_catalog_models.dart';

/// Horizontal category chips (reference-style).
class HomeCategoryStrip extends StatelessWidget {
  const HomeCategoryStrip({
    super.key,
    required this.categories,
    required this.onSelected,
  });

  final List<HomeCategory> categories;
  final ValueChanged<int> onSelected;

  static const List<_MockCategoryItem> _displayItems = [
    _MockCategoryItem(emoji: '🍔', label: 'Burger'),
    _MockCategoryItem(emoji: '🍕', label: 'Pizza'),
    _MockCategoryItem(emoji: '🍜', label: 'Noodles'),
    _MockCategoryItem(emoji: '🍗', label: 'Chicken'),
    _MockCategoryItem(emoji: '🥗', label: 'Vegetar..'),
    _MockCategoryItem(emoji: '🍰', label: 'Cake'),
    _MockCategoryItem(emoji: '🍺', label: 'Beer'),
    _MockCategoryItem(emoji: '🥙', label: 'Others'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final items = _displayItems;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 14,
          crossAxisSpacing: 10,
          childAspectRatio: 0.84,
        ),
        itemBuilder: (context, i) {
          final item = items[i];
          final tileColor = isDark ? cs.surfaceContainerHigh : Colors.white;
          final tileBorder = isDark
              ? cs.outlineVariant.withValues(alpha: 0.38)
              : Colors.white.withValues(alpha: 0.88);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelected(i % categories.length),
              child: Ink(
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: tileBorder),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : MndBrandColors.navy)
                          .withValues(alpha: isDark ? 0.24 : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            MndBrandColors.tealBlue,
                            MndBrandColors.royal,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: MndBrandColors.tealBlue.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? cs.onSurface : MndBrandColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MockCategoryItem {
  const _MockCategoryItem({required this.emoji, required this.label});

  final String emoji;
  final String label;
}
