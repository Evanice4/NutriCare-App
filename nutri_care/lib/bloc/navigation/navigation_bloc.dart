import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';
import '../search/search_bloc.dart';
import '../search/search_event.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final SearchBloc? searchBloc;
  
  NavigationBloc({this.searchBloc}) : super(const NavigationState()) {
    on<NavigateToTab>(_onNavigateToTab);
  }

  void _onNavigateToTab(NavigateToTab event, Emitter<NavigationState> emit) {
    // Clear search state when switching tabs
    searchBloc?.add(ClearSearch());
    emit(state.copyWith(currentIndex: event.tabIndex));
  }
}