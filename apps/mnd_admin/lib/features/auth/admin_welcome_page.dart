import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnd_theme/mnd_theme.dart';

import 'admin_auth_colors.dart';

/// Landing screen (reference: soft organic gradient, welcome + bottom CTAs).
class AdminWelcomePage extends StatelessWidget {
  const AdminWelcomePage({
    super.key,
    required this.onLogin,
  });

  final VoidCallback onLogin;

  static const _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final accent = AdminAuthColors.emphasis;
    final cta = AdminAuthColors.primary;
    final titleBase = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w600,
          height: 1.25,
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MndBrandColors.powder,
              MndBrandColors.sky,
              MndBrandColors.blueTeal,
              MndBrandColors.royal,
            ],
            stops: [0.0, 0.38, 0.68, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const MndBrandLogo(
                      size: 80,
                      backgroundColor: MndBrandColors.royal,
                      foregroundColor: _white,
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: Text.rich(
                        TextSpan(
                          style: titleBase,
                          children: [
                            const TextSpan(text: 'Welcome to '),
                            TextSpan(
                              text: 'MND Admin',
                              style: titleBase?.copyWith(
                                color: cta,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Fast. Reliable. Delivered.',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: accent.withValues(alpha: 0.9),
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Center(
                  child: Semantics(
                    button: true,
                    label: 'Log in',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onLogin,
                        customBorder: const CircleBorder(),
                        child: Ink(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFBDD8E9),
                              width: 2.25,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: _white,
                              size: 44,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
