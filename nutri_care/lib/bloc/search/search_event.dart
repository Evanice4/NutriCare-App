import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchGuides extends SearchEvent {
  final String query;
  final String? category;

  const SearchGuides({required this.query, this.category});

  @override
  List<Object?> get props => [query, category];
}

class SearchRecipes extends SearchEvent {
  final String query;

  const SearchRecipes({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchAlerts extends SearchEvent {
  final String query;

  const SearchAlerts({required this.query});

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {}