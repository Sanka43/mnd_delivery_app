import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnd_theme/mnd_theme.dart';

import 'admin_auth_colors.dart';

/// Login form (reference layout: gradient blobs, white sheet, brand-blue CTA).
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  static const _primary = AdminAuthColors.primary;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? e.code);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _fieldDecoration(String hint, {Widget? suffix}) {
    const r = BorderRadius.all(Radius.circular(12));
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AdminAuthColors.hintGray,
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: const OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: AdminAuthColors.inputBorder),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: AdminAuthColors.inputBorder),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            // Top gradient blob
            Positioned(
              top: -72,
              left: -48,
              right: -48,
              height: 240,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(120),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AdminAuthColors.blobTopA,
                      AdminAuthColors.blobTopB,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, top: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: widget.onBack != null
                                  ? IconButton(
                                      onPressed: widget.onBack,
                                      icon: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                      ),
                                      color: _primary,
                                      tooltip: MaterialLocalizations.of(
                                        context,
                                      ).backButtonTooltip,
                                    )
                                  : const SizedBox(height: 48),
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, viewport) {
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    0,
                                    24,
                                    16,
                                  ),
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: viewport.maxHeight,
                                    ),
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 420,
                                        ),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const MndBrandLogo(
                                                size: 72,
                                                backgroundColor:
                                                    AdminAuthColors.primary,
                                                foregroundColor: Colors.white,
                                              ),
                                              const SizedBox(height: 22),
                                              Text(
                                                'MND Admin',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: AdminAuthColors
                                                          .hintGray,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Login',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(
                                                      color: AdminAuthColors
                                                          .emphasis,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: -0.5,
                                                    ),
                                              ),
                                              const SizedBox(height: 28),
                                              TextFormField(
                                                controller: _email,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                textInputAction:
                                                    TextInputAction.next,
                                                autofillHints: const [
                                                  AutofillHints.email,
                                                ],
                                                style: const TextStyle(
                                                  color: Color(0xFF424242),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                decoration: _fieldDecoration(
                                                  'E-mail address',
                                                ),
                                                validator: (v) {
                                                  final s = v?.trim() ?? '';
                                                  if (s.isEmpty) {
                                                    return 'Enter your email';
                                                  }
                                                  if (!s.contains('@')) {
                                                    return 'Enter a valid email';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 14),
                                              TextFormField(
                                                controller: _password,
                                                obscureText: _obscurePassword,
                                                textInputAction:
                                                    TextInputAction.done,
                                                onFieldSubmitted: (_) =>
                                                    _signIn(),
                                                autofillHints: const [
                                                  AutofillHints.password,
                                                ],
                                                style: const TextStyle(
                                                  color: Color(0xFF424242),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                decoration: _fieldDecoration(
                                                  'Password',
                                                  suffix: IconButton(
                                                    onPressed: () => setState(
                                                      () => _obscurePassword =
                                                          !_obscurePassword,
                                                    ),
                                                    icon: Icon(
                                                      _obscurePassword
                                                          ? Icons
                                                                .visibility_off_outlined
                                                          : Icons
                                                                .visibility_outlined,
                                                      color: AdminAuthColors
                                                          .hintGray,
                                                    ),
                                                  ),
                                                ),
                                                validator: (v) {
                                                  if (v == null || v.isEmpty) {
                                                    return 'Enter your password';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 22),
                                              SizedBox(
                                                height: 52,
                                                child: FilledButton(
                                                  onPressed: _loading
                                                      ? null
                                                      : _signIn,
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor: _primary,
                                                    foregroundColor:
                                                        Colors.white,
                                                    disabledBackgroundColor:
                                                        _primary.withValues(
                                                          alpha: 0.5,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  child: _loading
                                                      ? const SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth:
                                                                    2.5,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        )
                                                      : const Text(
                                                          'Login',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              if (_error != null) ...[
                                                const SizedBox(height: 12),
                                                Text(
                                                  _error!,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.error,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AdminAuthColors.blobBottomA,
                            AdminAuthColors.blobBottomB,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withValues(
                                        alpha: 0.28,
                                      ),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'or continue with Google',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: MndBrandColors.powder
                                                .withValues(alpha: 0.92),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withValues(
                                        alpha: 0.28,
                                      ),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _socialStub(context),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF3C4043),
                                    side: const BorderSide(
                                      color: Color(0xFFDADCE0),
                                      width: 1,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    minimumSize: const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const _GoogleGlyph(size: 22),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Continue with Google',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF3C4043),
                                              letterSpacing: 0.1,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Firestore role must be "admin" for '
                                'dashboard access.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: MndBrandColors.sky.withValues(
                                        alpha: 0.88,
                                      ),
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _socialStub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-in is not configured yet.')),
    );
  }
}

/// Compact multi-colour “G” hint (brand colours; not the official Google mark).
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({required this.size});

  final double size;

  static const _brandBlue = Color(0xFF4285F4);
  static const _brandGreen = Color(0xFF34A853);
  static const _brandYellow = Color(0xFFFBBC05);
  static const _brandRed = Color(0xFFEA4335);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: const [
            _brandBlue,
            _brandGreen,
            _brandYellow,
            _brandRed,
            _brandBlue,
          ],
        ).createShader(bounds),
        child: Center(
          child: Text(
            'G',
            style: TextStyle(
              fontSize: size * 0.82,
              fontWeight: FontWeight.w800,
              height: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
