import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../data/customer_profile_repository.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class CustomerRegisterDetailsScreen extends StatefulWidget {
  const CustomerRegisterDetailsScreen({super.key});

  static const String lkDialCode = '+94';
  static const int localMobileDigits = 9;

  @override
  State<CustomerRegisterDetailsScreen> createState() =>
      _CustomerRegisterDetailsScreenState();
}

class _CustomerRegisterDetailsScreenState
    extends State<CustomerRegisterDetailsScreen> {
  final _profileRepository = CustomerProfileRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneLocalController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  bool _sending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneLocalController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  String get _e164Phone =>
      '${CustomerRegisterDetailsScreen.lkDialCode}${_phoneLocalController.text.trim()}';

  /// Firebase Auth: `admin-restricted-operation` when Anonymous sign-in is off.
  String _authRegisterErrorMessage(FirebaseAuthException e) {
    if (e.code == 'admin-restricted-operation') {
      return 'Anonymous sign-in is off in Firebase Console. '
          'Enable it: Authentication → Sign-in method → Anonymous → Enable.';
    }
    return e.message ?? 'Could not register now.';
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final phone = _e164Phone;

    setState(() => _sending = true);
    try {
      final auth = FirebaseAuth.instance;
      final credential =
          auth.currentUser != null ? null : await auth.signInAnonymously();
      final user = credential?.user ?? auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-unavailable',
          message: 'Could not create a user right now. Please try again.',
        );
      }

      await user.updateDisplayName(name);
      await _profileRepository.upsertProfile(
        uid: user.uid,
        fullName: name,
        phoneNumber: phone,
      );
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        message: 'Registration completed successfully.',
        icon: Icons.check_circle_outline_rounded,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: _authRegisterErrorMessage(e),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: e.message ?? '${e.code}: registration failed.',
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

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
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.royal.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 36,
                          color: AppColors.sky,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'MND',
                        style: TextStyle(
                          color: AppColors.sky,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
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
              child: ColoredBox(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 16 + bottomInset),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Full name',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'e.g. Nimal Perera',
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              _phoneFocusNode.requestFocus(),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Mobile number',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _LkPhoneField(
                          controller: _phoneLocalController,
                          focusNode: _phoneFocusNode,
                          onFieldSubmitted: (_) => _register(),
                        ),
                        const SizedBox(height: 6),
                        // Text(
                        //   '${CustomerRegisterDetailsScreen.localMobileDigits} digits '
                        //   '(e.g. 77 123 4567 → type 771234567)',
                        //   style: TextStyle(
                        //     fontSize: 12,
                        //     color: AppColors.blueMuted.withValues(alpha: 0.85),
                        //     height: 1.3,
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        CustomButton(
                          label: 'Register',
                          onPressed: _register,
                          isLoading: _sending,
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
    );
  }
}

class _LkPhoneField extends StatelessWidget {
  const _LkPhoneField({
    required this.controller,
    required this.focusNode,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String)? onFieldSubmitted;

  static String? _validateLocal(String? v) {
    final d = (v ?? '').trim().replaceAll(RegExp(r'\s'), '');
    if (d.isEmpty) {
      return 'Enter your mobile number';
    }
    if (d.length != CustomerRegisterDetailsScreen.localMobileDigits) {
      return 'Enter ${CustomerRegisterDetailsScreen.localMobileDigits} digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(d)) {
      return 'Digits only';
    }
    if (!d.startsWith('7')) {
      return 'Mobile should start with 7';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      maxLength: CustomerRegisterDetailsScreen.localMobileDigits,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onFieldSubmitted: onFieldSubmitted,
      validator: _validateLocal,
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.navy,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: AppColors.powder,
        hintText: '7XXXXXXXX',
        hintStyle: TextStyle(
          color: AppColors.blueMuted.withValues(alpha: 0.45),
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.tealBlue.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  CustomerRegisterDetailsScreen.lkDialCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.royal,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 26,
                color: AppColors.blueMuted.withValues(alpha: 0.25),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 52),
        contentPadding: const EdgeInsets.fromLTRB(8, 16, 18, 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.tealBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade600),
        ),
      ),
    );
  }
}

