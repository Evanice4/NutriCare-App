# 🧪 NutriCare Testing Guide

This guide provides comprehensive information about testing the NutriCare app, including unit tests, widget tests, and integration tests.

## 📋 Table of Contents

- [Testing Overview](#testing-overview)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Unit Tests](#unit-tests)
- [Widget Tests](#widget-tests)
- [Integration Tests](#integration-tests)
- [Mock Services](#mock-services)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## 🎯 Testing Overview

NutriCare uses a comprehensive testing strategy following the testing pyramid:

```
        🔺 Integration Tests (Few)
       /                        \
      /     Widget Tests          \
     /        (Some)               \
    /                               \
   /     Unit Tests (Many)           \
  /_____________________________________\
```

### Test Categories

1. **Unit Tests (70%)**: Test individual functions, methods, and BLoCs
2. **Widget Tests (20%)**: Test UI components and user interactions
3. **Integration Tests (10%)**: Test complete user flows and app behavior

## 📁 Test Structure

```
test/
├── unit/                           # Unit tests
│   ├── theme_bloc_test.dart       # Theme management tests
│   ├── user_bloc_test.dart        # User authentication tests
│   └── content_service_test.dart  # Content service tests
├── widget/                         # Widget tests
│   ├── theme_toggle_test.dart     # Theme toggle widget tests
│   ├── phone_auth_screen_test.dart # Phone auth UI tests
│   └── search_filter_test.dart    # Search functionality tests
├── integration/                    # Integration tests
│   └── app_integration_test.dart  # Complete app flow tests
├── mocks/                         # Mock services
│   ├── mock_auth_api.dart         # Mock authentication API
│   └── mock_content_service.dart  # Mock content service
├── test_runner.dart               # Test suite runner
├── bloc_test.dart                 # Navigation BLoC tests
├── search_bloc_test.dart          # Search BLoC tests
└── widget_test.dart               # Main widget tests
```

## 🚀 Running Tests

### Prerequisites

```bash
# Install dependencies
flutter pub get

# Install test dependencies
flutter pub deps
```

### Basic Test Commands

```bash
# Run all tests
flutter test

# Run specific test categories
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/

# Run specific test file
flutter test test/unit/theme_bloc_test.dart

# Run tests with coverage
flutter test --coverage

# Run tests in verbose mode
flutter test --verbose
```

### Advanced Test Commands

```bash
# Run tests with specific device
flutter test -d chrome

# Run tests with custom timeout
flutter test --timeout=60s

# Run tests and generate HTML coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🔧 Unit Tests

Unit tests focus on testing individual components in isolation.

### BLoC Testing Example

```dart
// test/unit/theme_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:nutri_care/bloc/theme/theme_bloc.dart';

void main() {
  group('ThemeBloc', () {
    late ThemeBloc themeBloc;

    setUp(() {
      themeBloc = ThemeBloc();
    });

    tearDown(() {
      themeBloc.close();
    });

    test('initial state is correct', () {
      expect(themeBloc.state, const ThemeState(isDarkMode: false));
    });

    blocTest<ThemeBloc, ThemeState>(
      'emits correct state when theme is toggled',
      build: () => themeBloc,
      act: (bloc) => bloc.add(ToggleTheme()),
      expect: () => [const ThemeState(isDarkMode: true)],
    );
  });
}
```

### Service Testing Example

```dart
// test/unit/content_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_care/services/content_service.dart';

void main() {
  group('ContentService', () {
    late ContentService contentService;

    setUp(() {
      contentService = ContentService();
    });

    test('throws exception when deleting non-existent recipe', () {
      expect(
        () => contentService.deleteRecipe('non-existent', 'user-id'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

## 🎨 Widget Tests

Widget tests verify UI components and user interactions.

### Theme Toggle Widget Test

```dart
// test/widget/theme_toggle_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_care/widgets/theme_toggle.dart';
import 'package:nutri_care/bloc/theme/theme_bloc.dart';

void main() {
  group('ThemeToggle Widget', () {
    testWidgets('displays correct icon for light mode', (tester) async {
      final themeBloc = ThemeBloc();
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ThemeBloc>(
            create: (context) => themeBloc,
            child: const Scaffold(body: ThemeToggle()),
          ),
        ),
      );

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.light_mode), findsNothing);
      
      themeBloc.close();
    });

    testWidgets('toggles theme when tapped', (tester) async {
      final themeBloc = ThemeBloc();
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ThemeBloc>(
            create: (context) => themeBloc,
            child: const Scaffold(body: ThemeToggle()),
          ),
        ),
      );

      // Tap the toggle button
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Should now show light mode icon
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      
      themeBloc.close();
    });
  });
}
```

### Form Validation Test

```dart
// test/widget/phone_auth_screen_test.dart
testWidgets('validates phone number input', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: PhoneAuthScreen()));

  // Try to submit without entering phone number
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  expect(find.text('Phone number is required'), findsOneWidget);
});
```

## 🔄 Integration Tests

Integration tests verify complete user flows and app behavior.

### App Flow Test

```dart
// test/integration/app_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutri_care/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('NutriCare App Integration Tests', () {
    testWidgets('complete app flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test app launch
      expect(find.text('NutriCare'), findsOneWidget);
      
      // Test theme toggle
      if (find.byIcon(Icons.dark_mode).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.dark_mode));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.light_mode), findsOneWidget);
      }

      // Test navigation
      if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) {
        final bottomNavItems = find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byType(BottomNavigationBarItem),
        );

        if (bottomNavItems.evaluate().length > 1) {
          await tester.tap(bottomNavItems.at(1));
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
```

## 🎭 Mock Services

Mock services simulate external dependencies for testing.

### Mock Authentication API

```dart
// test/mocks/mock_auth_api.dart
class MockAuthApi implements AuthApi {
  bool _shouldSucceed = true;
  UserProfile? _mockUser;

  void setShouldSucceed(bool shouldSucceed) {
    _shouldSucceed = shouldSucceed;
  }

  @override
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!_shouldSucceed) {
      return AuthResult(success: false, message: 'Login failed', user: null);
    }
    
    return AuthResult(
      success: true,
      message: 'Login successful',
      user: _mockUser ?? defaultTestUser,
    );
  }
}
```

### Using Mocks in Tests

```dart
void main() {
  group('UserBloc with Mock', () {
    late MockAuthApi mockAuthApi;
    late UserBloc userBloc;

    setUp(() {
      mockAuthApi = MockAuthApi();
      userBloc = UserBloc(authApi: mockAuthApi);
    });

    test('successful login', () async {
      mockAuthApi.setShouldSucceed(true);
      
      userBloc.add(LoginUser(email: 'test@example.com', password: 'password'));
      
      await expectLater(
        userBloc.stream,
        emitsInOrder([
          UserLoading(),
          isA<UserLoaded>(),
        ]),
      );
    });
  });
}
```

## ✅ Best Practices

### 1. Test Organization

```dart
void main() {
  group('FeatureName', () {
    group('SubFeature', () {
      test('should do something specific', () {
        // Test implementation
      });
    });
  });
}
```

### 2. Setup and Teardown

```dart
void main() {
  group('BlocName', () {
    late BlocName bloc;

    setUp(() {
      bloc = BlocName();
    });

    tearDown(() {
      bloc.close();
    });

    // Tests here
  });
}
```

### 3. Descriptive Test Names

```dart
// Good
test('should emit UserLoaded when login succeeds with valid credentials', () {});

// Bad
test('login test', () {});
```

### 4. Arrange-Act-Assert Pattern

```dart
test('should calculate total correctly', () {
  // Arrange
  final calculator = Calculator();
  final numbers = [1, 2, 3, 4, 5];

  // Act
  final result = calculator.sum(numbers);

  // Assert
  expect(result, equals(15));
});
```

### 5. Test Data Management

```dart
class TestData {
  static const testUser = UserProfile(
    uid: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    // ... other properties
  );

  static final testRecipe = Recipe(
    id: 'test-recipe-id',
    title: 'Test Recipe',
    // ... other properties
  );
}
```

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. SharedPreferences Mock Error

```dart
// Problem: SharedPreferences not mocked
// Solution: Add this in setUp()
SharedPreferences.setMockInitialValues({});
```

#### 2. Firebase Not Initialized

```dart
// Problem: Firebase not initialized in tests
// Solution: Use Firebase emulator or mock Firebase services
void main() {
  setUpAll(() async {
    await Firebase.initializeApp();
  });
}
```

#### 3. Widget Test Pump Issues

```dart
// Problem: Widget not fully rendered
// Solution: Use pumpAndSettle() instead of pump()
await tester.pumpAndSettle();
```

#### 4. BLoC Not Closed

```dart
// Problem: BLoC instances not properly closed
// Solution: Always close BLoCs in tearDown()
tearDown(() {
  bloc.close();
});
```

#### 5. Async Test Timing

```dart
// Problem: Async operations not completing
// Solution: Use proper async/await patterns
test('async operation', () async {
  final result = await someAsyncOperation();
  expect(result, isNotNull);
});
```

### Debug Test Output

```bash
# Run tests with debug output
flutter test --verbose

# Run specific test with debug
flutter test test/unit/theme_bloc_test.dart --verbose

# Check test coverage
flutter test --coverage
open coverage/html/index.html
```

## 📊 Coverage Goals

- **Overall Coverage**: > 80%
- **Unit Tests**: > 90%
- **Widget Tests**: > 70%
- **Integration Tests**: > 60%

### Generating Coverage Reports

```bash
# Generate coverage
flutter test --coverage

# Convert to HTML (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

## 🎯 Testing Checklist

### Before Committing
- [ ] All tests pass
- [ ] Coverage meets minimum requirements
- [ ] No test warnings or errors
- [ ] Mock services properly configured
- [ ] Integration tests cover main user flows

### Code Review
- [ ] Tests are readable and maintainable
- [ ] Test names are descriptive
- [ ] Edge cases are covered
- [ ] Mocks are used appropriately
- [ ] Tests follow established patterns

---

**Happy Testing! 🧪✨**

Remember: Good tests are an investment in code quality and developer confidence. Write tests that you and your team can understand and maintain.