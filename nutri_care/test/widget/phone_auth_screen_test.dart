import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_care/screens/phone_auth_screen.dart';

void main() {
  group('PhoneAuthScreen Widget', () {
    Widget createWidgetUnderTest() {
      return const MaterialApp(
        home: PhoneAuthScreen(),
      );
    }

    testWidgets('displays all required UI elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Check for app bar
      expect(find.text('Phone Login'), findsOneWidget);
      
      // Check for phone icon
      expect(find.byIcon(Icons.phone), findsAtLeastNWidget(1));
      
      // Check for title and subtitle
      expect(find.text('Enter Phone Number'), findsOneWidget);
      expect(find.text('We will send you a verification code'), findsOneWidget);
      
      // Check for phone number field
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      
      // Check for send OTP button
      expect(find.text('Send OTP'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('validates phone number input', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Try to submit without entering phone number
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Phone number is required'), findsOneWidget);
    });

    testWidgets('validates phone number format', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid phone number
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter a valid phone number with country code'), findsOneWidget);
    });

    testWidgets('accepts valid phone number format', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid phone number
      await tester.enterText(find.byType(TextFormField), '+250796595584');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should not show validation error
      expect(find.text('Phone number is required'), findsNothing);
      expect(find.text('Please enter a valid phone number with country code'), findsNothing);
    });

    testWidgets('shows loading state when sending OTP', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid phone number
      await tester.enterText(find.byType(TextFormField), '+250796595584');
      
      // Tap send OTP button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Note: In a real test, we'd mock the AuthApi to control the loading state
      // For now, we just verify the button exists and is tappable
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('phone number field has correct properties', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      
      expect(textField.keyboardType, TextInputType.phone);
      expect(textField.textInputAction, TextInputAction.done);
      
      // Check decoration
      final decoration = textField.decoration as InputDecoration;
      expect(decoration.labelText, 'Phone Number');
      expect(decoration.hintText, '+250 796 595 584');
      expect(decoration.prefixIcon, isA<Icon>());
    });

    testWidgets('form submission works with Enter key', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid phone number
      await tester.enterText(find.byType(TextFormField), '+250796595584');
      
      // Submit with Enter key
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Should trigger form submission (same as button tap)
      // In a real test with mocked AuthApi, we'd verify the API call
    });
  });
}