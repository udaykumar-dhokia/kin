import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // Brand Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.checkCheck,
                    color: theme.colorScheme.primaryForeground,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                AppConstants.appName,
                style: theme.textTheme.h1.copyWith(
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.muted.copyWith(
                  fontSize: 16,
                ),
              ),

              const Spacer(),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ShadButton(
                  onPressed: () {
                    // Navigate to sign up flow
                    ShadToaster.of(context).show(
                      const ShadToast(
                        title: Text('Get Started'),
                        description: Text('Sign up will be implemented in the next step.'),
                      ),
                    );
                  },
                  child: const Text('Create account'),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ShadButton.outline(
                  onPressed: () {
                    // Navigate to sign in flow
                    ShadToaster.of(context).show(
                      const ShadToast(
                        title: Text('Sign In'),
                        description: Text('Login will be implemented in the next step.'),
                      ),
                    );
                  },
                  child: const Text('Sign in'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
