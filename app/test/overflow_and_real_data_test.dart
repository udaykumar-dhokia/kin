import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';
import 'package:app/core/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'has_seen_onboarding': true,
      'auth_token': 'test_mock_jwt_token',
      'user_data':
          '{"id":"user_1","firstName":"Udaykumar","email":"udaykumar@test.com"}',
    });
    await StorageService.init();
    await StorageService.setHasSeenOnboarding(true);
    await StorageService.setAuthToken('test_mock_jwt_token');
    await StorageService.setUserData({
      'id': 'user_1',
      'firstName': 'Udaykumar',
      'email': 'udaykumar@test.com',
    });
  });

  testWidgets(
      'TodayScreen does NOT overflow on narrow 360px screen with long greeting name',
      (WidgetTester tester) async {
    // Standard compact Android screen: 360 x 640
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const KinApp());
    await tester.pumpAndSettle();

    // Verify greeting rendered without error
    expect(find.textContaining('Udaykumar 👋'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify clean real-state rendering
    expect(find.text('Upcoming Schedule'), findsOneWidget);
    expect(find.text('Total Upcoming'), findsOneWidget);
    expect(find.text('Active Deadlines'), findsOneWidget);
  });
}
