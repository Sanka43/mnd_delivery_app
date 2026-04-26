import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../auth/dev_phone_auth_bypass.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/custom_button.dart';
import 'customer_register_args.dart';

class CustomerOtpScreen extends StatefulWidget {
  const CustomerOtpScreen({super.key, required this.args});

  static const _kDevOtpCode = '1234';

  final CustomerOtpArgs args;

  @override
  State<CustomerOtpScreen> createState() => _CustomerOtpScreenState();
}

class _CustomerOtpScreenState extends State<CustomerOtpScreen> {
  final _codeController = TextEditingController();
  final _otpFocus = FocusNode();
  late String _verificationId;
  bool _verifying = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.args.verificationId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim();

    if (!kReleaseMode &&
        widget.args.isDevBypass &&
        code == CustomerOtpScreen._kDevOtpCode) {
      setState(() => _verifying = true);
      try {
        await signInWithDevOtpBypass(displayName: widget.args.fullName);
      } catch (e) {
        if (!mounted) return;
        AppSnackBar.showError(context, message: 'Dev sign-in failed: $e');
      } finally {
        if (mounted) setState(() => _verifying = false);
      }
      return;
    }

    if (code.length < 6) {
      AppSnackBar.showInfo(
        context,
        message: 'Enter the 6-digit code from SMS.',
        icon: Icons.sms_rounded,
      );
      return;
    }

    setState(() => _verifying = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseAuth.instance.currentUser?.updateDisplayName(
        widget.args.fullName,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, message: e.message ?? 'Invalid code.');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  void _resend() {
    if (!kReleaseMode && widget.args.isDevBypass) {
      AppSnackBar.showInfo(
        context,
        message: 'Dev mode enabled. Use code 1234; SMS is not sent.',
        icon: Icons.developer_mode_rounded,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _resending = true);
    final name = widget.args.fullName;
    final phone = widget.args.phoneNumber;

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
        } catch (_) {}
        if (mounted) setState(() => _resending = false);
      },
      verificationFailed: (e) {
        if (!mounted) return;
        setState(() => _resending = false);
        AppSnackBar.showError(
          context,
          message: e.message ?? 'Could not resend the code.',
        );
      },
      codeSent: (id, _) {
        if (!mounted) return;
        setState(() {
          _verificationId = id;
          _resending = false;
        });
        AppSnackBar.showSuccess(
          context,
          message: 'New code sent.',
          icon: Icons.mark_email_read_outlined,
        );
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 90),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final masked = _maskPhone(widget.args.phoneNumber);

    return Scaffold(
      backgroundColor: AppColors.navy,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        'Enter code',
                        style: TextStyle(
                          color: AppColors.powder,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        !kReleaseMode && widget.args.isDevBypass
                            ? 'Billing off / no SMS — debug: enter ${CustomerOtpScreen._kDevOtpCode}'
                            : 'We sent a verification code to\n$masked',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.powder.withValues(alpha: 0.9),
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: Material(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 20 + bottomInset),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _codeController,
                        focusNode: _otpFocus,
                        autofocus: true,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        maxLength: 6,
                        enableSuggestions: false,
                        autocorrect: false,
                        smartDashesType: SmartDashesType.disabled,
                        smartQuotesType: SmartQuotesType.disabled,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onFieldSubmitted: (_) => _verify(),
                        style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: false,
                          counterText: '',
                          hintText: !kReleaseMode && widget.args.isDevBypass
                              ? CustomerOtpScreen._kDevOtpCode
                              : '000000',
                          hintStyle: TextStyle(
                            color: AppColors.blueMuted.withValues(alpha: 0.4),
                            letterSpacing: 4,
                            fontSize: 24,
                          ),
                          filled: true,
                          fillColor: AppColors.powder,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.tealBlue,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        label: 'Verify & continue',
                        onPressed: _verify,
                        isLoading: _verifying,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _resending || _verifying ? null : _resend,
                        child: _resending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.tealBlue,
                                ),
                              )
                            : Text(
                                'Resend code',
                                style: TextStyle(
                                  color: AppColors.tealBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _maskPhone(String e164) {
    if (e164.length <= 6) return e164;
    final start = e164.substring(0, 4);
    final end = e164.substring(e164.length - 2);
    return '$start ••• ••• $end';
  }
}
