import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/screens/welcome_screen.dart';
import '../models/onboarding_slide.dart';
import '../widgets/illustration_placeholder.dart';
import '../widgets/onboarding_dots.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<OnboardingSlide> _slides = OnboardingSlide.slides;
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await StorageService.setHasSeenOnboarding(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isLastSlide = _currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: Brand name & Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (!isLastSlide)
                      ShadButton.ghost(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip',
                          style: theme.textTheme.muted.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ),

            // Middle: PageView (Illustration + Content)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),

                        // Illustration / Placeholder slot
                        IllustrationPlaceholder(slide: slide),

                        const Spacer(flex: 1),

                        // Badge Category
                        ShadBadge(
                          child: Text(
                            slide.badge,
                            style: const TextStyle(
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Slide Headline
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.h2.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Slide Subtitle (concise & clean)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.muted.copyWith(
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),

                        const Spacer(flex: 1),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Area: Indicators, Primary Action, and Sign In link
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots indicator
                  OnboardingDots(
                    count: _slides.length,
                    activeIndex: _currentIndex,
                  ),
                  const SizedBox(height: 24),

                  // Primary Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton(
                      onPressed: _onNext,
                      child: Text(
                        isLastSlide ? 'Get started' : 'Continue',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Login option
                  GestureDetector(
                    onTap: _completeOnboarding,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: theme.textTheme.muted.copyWith(fontSize: 13),
                          children: [
                            TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}
