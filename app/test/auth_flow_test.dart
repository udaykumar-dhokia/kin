import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';
import 'package:app/core/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'has_seen_onboarding': true,
      'auth_token': '',
    });
    await StorageService.init();
  });

  testWidgets('WelcomeScreen renders and navigates to LoginScreen and RegisterScreen',
      (WidgetTester tester) async {
    // Set realistic test screen size
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const KinApp());
    await tester.pumpAndSettle();

    // Verify WelcomeScreen
    expect(find.text('Kin'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    // Tap "Sign in" to open LoginScreen
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    // Verify LoginScreen contents
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Tap "Sign in" without entering fields -> shows error
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email address'), findsOneWidget);

    // Tap "Sign up" link to navigate to RegisterScreen
    final goToRegister = find.byKey(const Key('goToRegisterButton'));
    await tester.ensureVisible(goToRegister);
    await tester.tap(goToRegister);
    await tester.pumpAndSettle();

    // Verify RegisterScreen contents
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);

    // Tap "Create account" without entering fields -> shows error
    final createAccountBtn = find.text('Create account');
    await tester.ensureVisible(createAccountBtn);
    await tester.tap(createAccountBtn);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your first name'), findsOneWidget);

    // Tap "Sign in" link to navigate back to LoginScreen
    final goToLogin = find.byKey(const Key('goToLoginButton'));
    await tester.ensureVisible(goToLogin);
    await tester.tap(goToLogin);
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
