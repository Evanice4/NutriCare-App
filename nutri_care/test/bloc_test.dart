import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:nutri_care/bloc/navigation/navigation_bloc.dart';
import 'package:nutri_care/bloc/navigation/navigation_event.dart';
import 'package:nutri_care/bloc/navigation/navigation_state.dart';

void main() {
  group('NavigationBloc', () {
    late NavigationBloc navigationBloc;

    setUp(() {
      navigationBloc = NavigationBloc();
    });

    tearDown(() {
      navigationBloc.close();
    });

    test('initial state is NavigationState with currentIndex 0', () {
      expect(navigationBloc.state, const NavigationState(currentIndex: 0));
    });

    blocTest<NavigationBloc, NavigationState>(
      'emits [NavigationState(currentIndex: 1)] when NavigateToTab(1) is added',
      build: () => navigationBloc,
      act: (bloc) => bloc.add(const NavigateToTab(1)),
      expect: () => [const NavigationState(currentIndex: 1)],
    );

    blocTest<NavigationBloc, NavigationState>(
      'emits [NavigationState(currentIndex: 2)] when NavigateToTab(2) is added',
      build: () => navigationBloc,
      act: (bloc) => bloc.add(const NavigateToTab(2)),
      expect: () => [const NavigationState(currentIndex: 2)],
    );
  });
}