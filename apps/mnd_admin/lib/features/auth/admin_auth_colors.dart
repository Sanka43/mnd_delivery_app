import 'package:flutter/material.dart';
import 'package:mnd_theme/mnd_theme.dart';

/// Admin welcome + login — same blues as [MndBrandColors] / app theme.
abstract final class AdminAuthColors {
  /// Primary buttons, focus rings, key actions.
  static const primary = MndBrandColors.royal;

  /// Strong headline accent on light gradients.
  static const emphasis = MndBrandColors.navy;

  /// Field outlines (blue-tinted neutral).
  static const inputBorder = Color(0xFFB8C9D8);

  static const dividerLine = Color(0xFFA8BED0);

  static const hintGray = MndBrandColors.blueMuted;

  /// Login top blob: sea → sky.
  static const blobTopA = MndBrandColors.tealBlue;
  static const blobTopB = MndBrandColors.sky;

  /// Login bottom blob: royal → deep navy.
  static const blobBottomA = MndBrandColors.royal;
  static const blobBottomB = MndBrandColors.navy;
}
