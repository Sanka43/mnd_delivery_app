import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'mnd_brand_palette.dart';

/// Frosted-glass chrome on **iOS & Android** (skipped on web — blur cost).
bool get mndGlassChromeEnabled =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

/// Layered gradient behind glass so blur reads clearly.
class MndGlassBackdrop extends StatelessWidget {
  const MndGlassBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Brand gradient: light sky / powder at top → deep royal / navy at bottom.
    final colors = dark
        ? [
            Color.lerp(MndBrandColors.royal, MndBrandColors.sky, 0.28)!,
            MndBrandColors.royal,
            MndBrandColors.navy,
          ]
        : [
            MndBrandColors.powder,
            MndBrandColors.sky,
            MndBrandColors.tealBlue,
            MndBrandColors.royal,
          ];
    final stops = dark ? const [0.0, 0.55, 1.0] : const [0.0, 0.38, 0.72, 1.0];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ),
      ),
    );
  }
}

/// Frosted panel: backdrop blur + translucent fill + hairline border.
class MndGlassPanel extends StatelessWidget {
  const MndGlassPanel({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.blurSigma = 28,
    this.fillAlpha = 0.5,
    this.border,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double fillAlpha;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveBorder = border ??
        Border.all(
          color: scheme.onSurface.withValues(alpha: 0.07),
          width: 0.5,
        );
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: scheme.surface.withValues(alpha: fillAlpha),
            border: effectiveBorder,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Full-height sidebar blur (navigation rail).
class MndGlassRailBackdrop extends StatelessWidget {
  const MndGlassRailBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.48),
            border: Border(
              right: BorderSide(
                color: scheme.outline.withValues(alpha: 0.14),
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
