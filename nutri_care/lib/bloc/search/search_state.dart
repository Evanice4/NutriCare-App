import 'package:equatable/equatable.dart';
import '../../models/content_models.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchResults extends SearchState {
  final List<Guide> guides;
  final List<Recipe> recipes;
  final List<HealthAlert> alerts;
  final String query;

  const SearchResults({
    this.guides = const [],
    this.recipes = const [],
    this.alerts = const [],
    required this.query,
  });

  @override
  List<Object?> get props => [guides, recipes, alerts, query];
}