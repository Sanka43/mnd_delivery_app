import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mnd_glass.dart';

/// Auth / message screens: solid chrome on web & desktop, glass stack on mobile.
class MndLoginChrome extends StatelessWidget {
  const MndLoginChrome({
    super.key,
    this.brandHeader,
    required this.headline,
    required this.content,
  });

  /// Optional logo / tagline block shown above [headline] (e.g. brand mark).
  final Widget? brandHeader;
  final String headline;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = mndGlassChromeEnabled;
    final dark = theme.brightness == Brightness.dark;

    if (glass) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor:
              theme.colorScheme.surface.withValues(alpha: 0.94),
          systemNavigationBarIconBrightness:
              dark ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const MndGlassBackdrop(),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: MndGlassPanel(
                        borderRadius: BorderRadius.circular(20),
                        blurSigma: 26,
                        fillAlpha: dark ? 0.42 : 0.46,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (brandHeader != null) ...[
                                Center(child: brandHeader),
                                const SizedBox(height: 20),
                              ],
                              Text(
                                headline,
                                textAlign: brandHeader != null
                                    ? TextAlign.center
                                    : TextAlign.start,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              content,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(headline),
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (brandHeader != null) ...[
                  Center(child: brandHeader),
                  const SizedBox(height: 24),
                ],
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
