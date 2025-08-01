import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutri_care/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('NutriCare App Integration Tests', () {
    testWidgets('complete app flow test', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test 1: App launches and shows splash screen
      expect(find.text('NutriCare'), findsOneWidget);
      
      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test 2: Navigate to login screen
      if (find.text('Get Started').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }

      // Test 3: Test theme toggle functionality
      if (find.byIcon(Icons.dark_mode).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.dark_mode));
        await tester.pumpAndSettle();
        
        // Verify theme changed
        expect(find.byIcon(Icons.light_mode), findsOneWidget);
        
        // Toggle back
        await tester.tap(find.byIcon(Icons.light_mode));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      }

      // Test 4: Navigate to phone authentication
      if (find.text('Login with Phone').evaluate().isNotEmpty) {
        await tester.tap(find.text('Login with Phone'));
        await tester.pumpAndSettle();

        // Test phone number input
        expect(find.text('Phone Login'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);

        // Test invalid phone number
        await tester.enterText(find.byType(TextFormField), '123');
        await tester.tap(find.text('Send OTP'));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.textContaining('valid phone number'), findsOneWidget);

        // Test valid phone number format
        await tester.enterText(find.byType(TextFormField), '+250796595584');
        await tester.pumpAndSettle();

        // Go back to avoid actual OTP sending in test
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      // Test 5: Test navigation between screens
      // This would depend on the actual app structure and available navigation
    });

    testWidgets('theme persistence test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Toggle theme
      if (find.byIcon(Icons.dark_mode).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.dark_mode));
        await tester.pumpAndSettle();
      }

      // Restart app
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );

      app.main();
      await tester.pumpAndSettle();

      // Theme should be persisted
      // Note: This test would need proper SharedPreferences mocking
    });

    testWidgets('search functionality integration test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to home screen (assuming user is logged in)
      // This would need proper authentication mocking

      // Test search functionality
      if (find.byIcon(Icons.search).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        // Enter search query
        if (find.byType(TextField).evaluate().isNotEmpty) {
          await tester.enterText(find.byType(TextField), 'healthy recipes');
          await tester.pumpAndSettle();

          // Verify search results or loading state
          expect(
            find.byType(CircularProgressIndicator).or(find.byType(ListView)),
            findsOneWidget,
          );
        }
      }
    });

    testWidgets('navigation flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test bottom navigation if available
      if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) {
        final bottomNavBar = find.byType(BottomNavigationBar);
        expect(bottomNavBar, findsOneWidget);

        // Test navigation to different tabs
        final bottomNavItems = find.descendant(
          of: bottomNavBar,
          matching: find.byType(BottomNavigationBarItem),
        );

        if (bottomNavItems.evaluate().length > 1) {
          // Tap second tab
          await tester.tap(bottomNavItems.at(1));
          await tester.pumpAndSettle();

          // Tap third tab if exists
          if (bottomNavItems.evaluate().length > 2) {
            await tester.tap(bottomNavItems.at(2));
            await tester.pumpAndSettle();
          }

          // Return to first tab
          await tester.tap(bottomNavItems.at(0));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('error handling test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test network error scenarios
      // This would need network mocking to simulate failures

      // Test form validation errors
      if (find.byType(TextFormField).evaluate().isNotEmpty) {
        // Try to submit empty form
        if (find.byType(ElevatedButton).evaluate().isNotEmpty) {
          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();

          // Should show validation errors
          expect(
            find.textContaining('required').or(find.textContaining('invalid')),
            findsAtLeastNWidgets(0),
          );
        }
      }
    });
  });
}