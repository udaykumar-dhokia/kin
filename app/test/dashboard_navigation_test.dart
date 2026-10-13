import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/categories/widgets/category_card.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'has_seen_onboarding': true,
      'auth_token': 'test_mock_jwt_token',
      'user_data': '{"id":"user_1","firstName":"Uday","email":"uday@test.com"}',
    });
    await StorageService.init();
    await StorageService.setHasSeenOnboarding(true);
    await StorageService.setAuthToken('test_mock_jwt_token');
    await StorageService.setUserData({
      'id': 'user_1',
      'firstName': 'Uday',
      'email': 'uday@test.com',
    });
  });

  testWidgets(
      'Dashboard shell renders with 5-tab bottom nav, Categories hub, and consistent FAB bottom sheets',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const KinApp());
    await tester.pumpAndSettle();

    // 1. Verify Today screen is displayed initially
    expect(find.textContaining('Uday 👋'), findsOneWidget);
    expect(find.text('Upcoming Schedule'), findsOneWidget);
    expect(find.text('Total Upcoming'), findsOneWidget);

    // Verify all 5 bottom nav tabs
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify FAB on Today screen opens AddBillBottomSheet
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add Deadline'), findsWidgets);
    // Dismiss bottom sheet by tapping close icon
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();

    // 2. Switch to Categories tab
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Bills & Payments'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Insurance'), findsOneWidget);
    expect(find.text('Vehicles'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Subscriptions'), findsOneWidget);
    expect(find.text('Family'), findsWidgets);
    // Test search filter in Categories hub
    await tester.enterText(find.byType(EditableText).first, 'Appointments');
    await tester.pumpAndSettle();
    expect(
        find.widgetWithText(CategoryCard, 'Appointments'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).first, '');
    await tester.pumpAndSettle();

    // Tap a Coming Soon category (Documents) -> opens CategoryComingSoonBottomSheet
    await tester.tap(find.text('Documents'));
    await tester.pumpAndSettle();
    expect(find.text('COMING SOON'), findsOneWidget);
    expect(find.text('What to expect'), findsOneWidget);
    // Dismiss bottom sheet
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();

    // Tap live category 'Bills & Payments' in Categories hub -> navigates to Bills tab
    await tester.tap(find.text('Bills & Payments'));
    await tester.pumpAndSettle();
    expect(find.text('Bills & Deadlines'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);

    // Verify FAB on Bills tab opens AddBillBottomSheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add Deadline'), findsWidgets);
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();

    // 3. Switch to Family tab
    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    expect(find.text('Household'), findsOneWidget);

    // Verify FAB on Family tab opens AddMemberBottomSheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add Family Member'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Relationship'), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();

    // 4. Switch to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);

    // 5. Switch back to Today tab
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming Schedule'), findsOneWidget);
  });
}
