import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';
import 'package:app/core/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'has_seen_onboarding': false,
    });
    await StorageService.init();
    await StorageService.setHasSeenOnboarding(false);
    await StorageService.clearAuth();
  });

  testWidgets('Onboarding flow smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build KinApp
    await tester.pumpWidget(const KinApp());
    await tester.pumpAndSettle();

    // Verify slide 1 is displayed
    expect(find.text('DEADLINES'), findsOneWidget);
    expect(find.text('Never miss what matters.'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Tap Continue to go to slide 2
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify slide 2
    expect(find.text('HOUSEHOLD'), findsOneWidget);
    expect(find.text('Keep everyone in sync.'), findsOneWidget);

    // Tap Continue to go to slide 3
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify slide 3
    expect(find.text('AUTOMATION'), findsOneWidget);
    expect(find.text('Set once. Relax forever.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    // Skip button should be hidden on final slide
    expect(find.text('Skip'), findsNothing);

    // Tap Get started to complete onboarding
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Verify WelcomeScreen is displayed
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(StorageService.hasSeenOnboarding(), isTrue);
  });

  testWidgets('Skip button navigates to WelcomeScreen directly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build KinApp
    await tester.pumpWidget(const KinApp());
    await tester.pumpAndSettle();

    // Tap Skip on slide 1
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Verify WelcomeScreen is displayed
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(StorageService.hasSeenOnboarding(), isTrue);
  });
}
