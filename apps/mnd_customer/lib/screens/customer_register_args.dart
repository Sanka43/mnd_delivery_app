class CustomerOtpArgs {
  const CustomerOtpArgs({
    required this.fullName,
    required this.phoneNumber,
    required this.verificationId,
  });

  static const devBypassVerificationId = '__DEV_OTP_BYPASS__';

  final String fullName;
  final String phoneNumber;
  final String verificationId;

  bool get isDevBypass => verificationId == devBypassVerificationId;
}
