import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'core/constants/app_constants.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(const KinApp());
}

class KinApp extends StatelessWidget {
  const KinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hasSeenOnboarding = StorageService.hasSeenOnboarding();

    return ShadApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: hasSeenOnboarding
          ? const WelcomeScreen()
          : const OnboardingScreen(),
    );
  }
}
