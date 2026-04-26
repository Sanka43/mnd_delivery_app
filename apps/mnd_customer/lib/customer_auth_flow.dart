import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/customer_otp_screen.dart';
import 'screens/customer_register_args.dart';
import 'screens/customer_register_details_screen.dart';
import 'screens/onboarding_screen.dart';

abstract final class CustomerAuthRoutes {
  static const onboarding = '/onboarding';
  static const setup = '/setup';
  static const otp = '/otp';
}

class CustomerAuthFlow extends StatelessWidget {
  const CustomerAuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Navigator(
        initialRoute: CustomerAuthRoutes.onboarding,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case CustomerAuthRoutes.onboarding:
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const OnboardingScreen(),
              );
            case CustomerAuthRoutes.setup:
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const CustomerRegisterDetailsScreen(),
              );
            case CustomerAuthRoutes.otp:
              final args = settings.arguments as CustomerOtpArgs?;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => args == null
                    ? const CustomerRegisterDetailsScreen()
                    : CustomerOtpScreen(args: args),
              );
            default:
              return MaterialPageRoute<void>(
                builder: (_) => const OnboardingScreen(),
              );
          }
        },
      ),
    );
  }
}
