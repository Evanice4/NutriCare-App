import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutri_care/widgets/theme_toggle.dart';
import 'package:nutri_care/bloc/theme/theme_bloc.dart';

void main() {
  group('ThemeToggle Widget', () {
    late ThemeBloc themeBloc;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      themeBloc = ThemeBloc();
    });

    tearDown(() {
      themeBloc.close();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<ThemeBloc>(
          create: (context) => themeBloc,
          child: const Scaffold(
            body: ThemeToggle(),
          ),
        ),
      );
    }

    testWidgets('displays dark mode icon when in light mode', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.light_mode), findsNothing);
    });

    testWidgets('displays light mode icon when in dark mode', (tester) async {
      themeBloc.add(ToggleTheme());
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsNothing);
    });

    testWidgets('toggles theme when tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initially in light mode
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      // Tap the toggle button
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Should now be in dark mode
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsNothing);
    });

    testWidgets('is accessible', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(IconButton), findsOneWidget);
      
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNotNull);
    });
  });
}