import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

/// Hero promo card — gradient + CTA + food image (reference layout).
class HomePromoBanner extends StatefulWidget {
  const HomePromoBanner({super.key, required this.onOrderNow});

  final VoidCallback onOrderNow;

  @override
  State<HomePromoBanner> createState() => _HomePromoBannerState();
}

class _HomePromoBannerState extends State<HomePromoBanner> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final titleColor = isDark ? cs.onSurface : MndBrandColors.navy;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Special offers',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              TextButton(
                onPressed: widget.onOrderNow,
                child: Text(
                  'See all',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: MndBrandColors.tealBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: widget.onOrderNow,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 156,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [MndBrandColors.tealBlue, MndBrandColors.royal],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MndBrandColors.tealBlue.withValues(
                        alpha: isDark ? 0.3 : 0.24,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -10,
                      right: -8,
                      child: Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -24,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
                      child: Row(
                        children: [
                          const Expanded(child: _OfferTextBlock()),
                          Expanded(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.lunch_dining_rounded,
                                size: 72,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferTextBlock extends StatelessWidget {
  const _OfferTextBlock();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '30%',
          style: theme.textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            height: 0.95,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'off from\nchicken burger',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.94),
            fontWeight: FontWeight.w700,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}
