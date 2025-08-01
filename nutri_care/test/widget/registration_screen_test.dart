import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_care/screens/registration_screen.dart';

void main() {
  group('RegistrationScreen Validation Tests', () {
    Widget createWidgetUnderTest(String userType) {
      return MaterialApp(
        home: RegistrationScreen(userType: userType),
      );
    }

    testWidgets('validates full name field', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest('member'));

      // Test empty name
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Full name is required'), findsOneWidget);

      // Test short name
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Name must be at least 2 characters'), findsOneWidget);

      // Test invalid characters
      await tester.enterText(find.byType(TextFormField).first, 'John123');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Name can only contain letters and spaces'), findsOneWidget);

      // Test valid name
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Full name is required'), findsNothing);
    });

    testWidgets('validates email field', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest('member'));

      final emailField = find.byType(TextFormField).at(1);

      // Test empty email
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);

      // Test invalid email format
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Test valid email
      await tester.enterText(emailField, 'test@example.com');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Email is required'), findsNothing);
    });

    testWidgets('validates password field', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest('member'));

      final passwordField = find.byType(TextFormField).at(2);

      // Test empty password
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Password is required'), findsOneWidget);

      // Test short password
      await tester.enterText(passwordField, '123');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);

      // Test weak password
      await tester.enterText(passwordField, 'password');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Password must contain uppercase, lowercase, and number'), findsOneWidget);

      // Test valid password
      await tester.enterText(passwordField, 'Password123');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Password is required'), findsNothing);
    });

    testWidgets('validates password confirmation', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest('member'));

      final passwordField = find.byType(TextFormField).at(2);
      final confirmPasswordField = find.byType(TextFormField).at(3);

      // Enter different passwords
      await tester.enterText(passwordField, 'Password123');
      await tester.enterText(confirmPasswordField, 'Password456');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);

      // Enter matching passwords
      await tester.enterText(confirmPasswordField, 'Password123');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('shows creator-specific validation', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest('creator'));

      expect(find.text('Register as Creator'), findsOneWidget);
      expect(find.text('Professional Certificate (Optional)'), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest('member'));

      final passwordField = find.byType(TextFormField).at(2);
      final visibilityIcon = find.byIcon(Icons.visibility).first;

      // Initially password should be obscured
      final textField = tester.widget<TextFormField>(passwordField);
      expect(textField.obscureText, true);

      // Tap visibility toggle
      await tester.tap(visibilityIcon);
      await tester.pump();

      // Password should now be visible
      final updatedTextField = tester.widget<TextFormField>(passwordField);
      expect(updatedTextField.obscureText, false);
    });
  });
}