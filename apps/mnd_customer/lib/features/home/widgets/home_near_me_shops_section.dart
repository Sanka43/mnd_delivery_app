import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

import '../../../widgets/app_snackbar.dart';
import '../models/home_catalog_models.dart';

/// Horizontal "Near me" shops — wide cards, gradient image treatment, soft motion.
class HomeNearMeShopsSection extends StatelessWidget {
  const HomeNearMeShopsSection({
    super.key,
    required this.shops,
    this.onShopTap,
  });

  final List<HomeNearShop> shops;
  final ValueChanged<HomeNearShop>? onShopTap;

  static String _formatKm(double km) {
    if (km < 10) {
      return km == km.roundToDouble() ? '${km.toInt()} km' : '${km.toStringAsFixed(1)} km';
    }
    return '${km.round()} km';
  }

  void _onSeeAll(BuildContext context) {
    AppSnackBar.showInfo(
      context,
      message: 'Map and full list are coming soon.',
      icon: Icons.map_rounded,
    );
  }

  void _onShopPressed(BuildContext context, HomeNearShop shop) {
    if (onShopTap != null) {
      onShopTap!(shop);
    } else {
      AppSnackBar.showInfo(
        context,
        message: '${shop.name} — opening soon.',
        icon: Icons.storefront_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    if (shops.isEmpty) return const SizedBox.shrink();

    final titleColor = isDark ? cs.onSurface : MndBrandColors.navy;
    final subtitleColor = isDark ? cs.onSurfaceVariant : MndBrandColors.blueMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MndBrandColors.tealBlue,
                      MndBrandColors.royal,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MndBrandColors.tealBlue.withValues(alpha: isDark ? 0.35 : 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.near_me_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Near you',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        height: 1.1,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Local picks by distance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onSeeAll(context),
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See all',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: MndBrandColors.tealBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: MndBrandColors.tealBlue.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 248,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 20, right: 8),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: shops.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final shop = shops[i];
              return _NearMeShopCard(
                shop: shop,
                isDark: isDark,
                formatKm: _formatKm,
                onTap: () => _onShopPressed(context, shop),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NearMeShopCard extends StatefulWidget {
  const _NearMeShopCard({
    required this.shop,
    required this.isDark,
    required this.formatKm,
    required this.onTap,
  });

  final HomeNearShop shop;
  final bool isDark;
  final String Function(double km) formatKm;
  final VoidCallback onTap;

  @override
  State<_NearMeShopCard> createState() => _NearMeShopCardState();
}

class _NearMeShopCardState extends State<_NearMeShopCard> {
  static const _kPressScale = 0.97;

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final shop = widget.shop;

    final shadowColor = widget.isDark
        ? Colors.black.withValues(alpha: 0.45)
        : MndBrandColors.navy.withValues(alpha: 0.12);

    final borderColor = widget.isDark
        ? cs.outlineVariant.withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.85);

    return AnimatedScale(
      scale: _pressed ? _kPressScale : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: 210,
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: MndBrandColors.tealBlue.withValues(alpha: widget.isDark ? 0.08 : 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Material(
                color: widget.isDark ? cs.surfaceContainerHigh : Colors.white,
                child: InkWell(
                  onTap: widget.onTap,
                  onHighlightChanged: (v) => setState(() => _pressed = v),
                  splashColor: MndBrandColors.tealBlue.withValues(alpha: 0.15),
                  highlightColor: MndBrandColors.sky.withValues(alpha: 0.08),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              shop.imageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return ColoredBox(
                                  color: widget.isDark
                                      ? cs.surfaceContainerHighest
                                      : MndBrandColors.powder,
                                  child: Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: MndBrandColors.tealBlue.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: widget.isDark
                                    ? cs.surfaceContainerHighest
                                    : MndBrandColors.powder,
                                child: Icon(
                                  Icons.storefront_rounded,
                                  size: 48,
                                  color: MndBrandColors.blueMuted.withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.02),
                                    Colors.black.withValues(alpha: 0.08),
                                    Colors.black.withValues(alpha: 0.72),
                                  ],
                                  stops: const [0.0, 0.45, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: _GlassChip(
                              icon: Icons.star_rounded,
                              label: shop.rating.toStringAsFixed(1),
                              trailing: shop.reviewCount > 0 ? ' (${shop.reviewCount})' : null,
                              iconColor: const Color(0xFFFFC94A),
                              isDark: widget.isDark,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: _GlassChip(
                              icon: Icons.route_rounded,
                              label: widget.formatKm(shop.distanceKm),
                              iconColor: const Color(0xFF7AE8C8),
                              isDark: widget.isDark,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    shop.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                      letterSpacing: -0.2,
                                      color: Colors.white,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x66000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.store_mall_directory_rounded,
                                        size: 15,
                                        color: Colors.white.withValues(alpha: 0.88),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Tap to browse',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withValues(alpha: 0.82),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.icon,
    required this.label,
    this.trailing,
    required this.iconColor,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final Color iconColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frosted = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.22);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: frosted,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                if (trailing != null)
                  Text(
                    trailing!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.75),
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
