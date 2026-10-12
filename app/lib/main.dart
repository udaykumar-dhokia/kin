import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'core/constants/app_constants.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
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
    final isLoggedIn = StorageService.isLoggedIn();

    Widget initialScreen;
    if (!hasSeenOnboarding) {
      initialScreen = const OnboardingScreen();
    } else if (isLoggedIn) {
      initialScreen = const DashboardScreen();
    } else {
      initialScreen = const WelcomeScreen();
    }

    return ShadApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: initialScreen,
    );
  }
}
