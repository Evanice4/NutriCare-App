import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutri_care/bloc/theme/theme_bloc.dart';

void main() {
  group('ThemeBloc', () {
    late ThemeBloc themeBloc;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      themeBloc = ThemeBloc();
    });

    tearDown(() {
      themeBloc.close();
    });

    test('initial state is ThemeState with isDarkMode false', () {
      expect(themeBloc.state, const ThemeState(isDarkMode: false));
    });

    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeState(isDarkMode: true)] when ToggleTheme is added',
      build: () => themeBloc,
      act: (bloc) => bloc.add(ToggleTheme()),
      expect: () => [const ThemeState(isDarkMode: true)],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeState(isDarkMode: false)] when ToggleTheme is added twice',
      build: () => themeBloc,
      act: (bloc) {
        bloc.add(ToggleTheme());
        bloc.add(ToggleTheme());
      },
      expect: () => [
        const ThemeState(isDarkMode: true),
        const ThemeState(isDarkMode: false),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'loads saved theme preference',
      setUp: () {
        SharedPreferences.setMockInitialValues({'theme_mode': true});
      },
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(LoadTheme()),
      expect: () => [const ThemeState(isDarkMode: true)],
    );
  });
}