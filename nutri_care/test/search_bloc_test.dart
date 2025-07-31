import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:nutri_care/bloc/search/search_bloc.dart';
import 'package:nutri_care/bloc/search/search_event.dart';
import 'package:nutri_care/bloc/search/search_state.dart';
import 'package:nutri_care/bloc/content/content_bloc.dart';
import 'package:nutri_care/bloc/content/content_state.dart';
import 'package:nutri_care/models/content_models.dart';

void main() {
  group('SearchBloc', () {
    late SearchBloc searchBloc;
    late ContentBloc mockContentBloc;

    setUp(() {
      mockContentBloc = ContentBloc();
      searchBloc = SearchBloc(contentBloc: mockContentBloc);
    });

    tearDown(() {
      searchBloc.close();
      mockContentBloc.close();
    });

    test('initial state is SearchInitial', () {
      expect(searchBloc.state, SearchInitial());
    });

    blocTest<SearchBloc, SearchState>(
      'emits SearchInitial when ClearSearch is added',
      build: () => searchBloc,
      act: (bloc) => bloc.add(ClearSearch()),
      expect: () => [SearchInitial()],
    );
  });
}