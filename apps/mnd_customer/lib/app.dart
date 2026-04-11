import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mnd_customer/features/home/customer_home_page.dart';
import 'package:mnd_theme/mnd_theme.dart';

/// Debug builds only: skip SMS when OTP matches [ _kDevOtpBypass ].
/// Tries email/password first, then anonymous (Firebase may block anonymous).
/// Create this user once: Firebase Console → Authentication → Users → Add user
/// (same email/password as below), and enable Email/Password sign-in method.
const String _kDevOtpBypass = '1234';
const String _kDevEmail = 'dev@mnd.delivery';
const String _kDevPassword = 'MndDevOnly123!';

/// Root widget for the customer app.
class MndCustomerApp extends StatelessWidget {
  const MndCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MND Delivery',
      debugShowCheckedModeBanner: false,
      theme: MndAppTheme.light,
      darkTheme: MndAppTheme.dark,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final theme = Theme.of(context);
        final dark = theme.brightness == Brightness.dark;
        final overlay = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: theme.colorScheme.surface,
          systemNavigationBarIconBrightness:
              dark ? Brightness.light : Brightness.dark,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data != null) {
          return CustomerHomePage(user: snapshot.data!);
        }

        return const PhoneOtpLoginPage();
      },
    );
  }
}

class PhoneOtpLoginPage extends StatefulWidget {
  const PhoneOtpLoginPage({super.key});

  @override
  State<PhoneOtpLoginPage> createState() => _PhoneOtpLoginPageState();
}

class _PhoneOtpLoginPageState extends State<PhoneOtpLoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  String? _verificationId;
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !phone.startsWith('+')) {
      setState(() {
        _message =
            'Enter your phone number in international format (e.g. +94771234567).';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        setState(() {
          _loading = false;
          _message = e.message ?? 'Could not send the verification code.';
        });
      },
      codeSent: (verificationId, _) {
        setState(() {
          _loading = false;
          _verificationId = verificationId;
          _message = 'Verification code sent.';
        });
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();

    if (kDebugMode && code == _kDevOtpBypass) {
      setState(() {
        _loading = true;
        _message = null;
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _kDevEmail,
          password: _kDevPassword,
        );
      } on FirebaseAuthException catch (e) {
        try {
          await FirebaseAuth.instance.signInAnonymously();
        } on FirebaseAuthException catch (e2) {
          if (!mounted) return;
          final detail =
              'Dev login failed.\n'
              '• Firebase → Authentication → Sign-in method: enable Email/Password, '
              'add user $_kDevEmail with password from code (or your own).\n'
              '• Or enable Anonymous sign-in.\n'
              'Errors: ${e.code} / ${e2.code}';
          setState(() => _message = detail);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dev login failed (${e2.code})')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
      return;
    }

    if (_verificationId == null || code.length < 6) {
      setState(() {
        _message = 'Enter a valid 6-digit code.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message ?? 'Could not verify the code.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MndLoginChrome(
      headline: 'MND — Customer login',
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '+94…',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _sendOtp,
            child: const Text('Send OTP'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Verification code',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _loading ? null : _verifyOtp,
            child: const Text('Verify & Login'),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 12),
            Text(
              'Dev only: enter $_kDevOtpBypass, then Verify — uses '
              '$_kDevEmail (create in Firebase) or falls back to Anonymous.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
          if (_loading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(
              _message!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
