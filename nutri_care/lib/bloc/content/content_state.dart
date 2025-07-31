import 'package:equatable/equatable.dart';
import '../../models/content_models.dart';

abstract class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class ContentLoaded extends ContentState {
  final List<Guide> guides;
  final List<Recipe> recipes;
  final List<HealthAlert> alerts;

  const ContentLoaded({
    this.guides = const [],
    this.recipes = const [],
    this.alerts = const [],
  });

  ContentLoaded copyWith({
    List<Guide>? guides,
    List<Recipe>? recipes,
    List<HealthAlert>? alerts,
  }) {
    return ContentLoaded(
      guides: guides ?? this.guides,
      recipes: recipes ?? this.recipes,
      alerts: alerts ?? this.alerts,
    );
  }

  @override
  List<Object> get props => [guides, recipes, alerts];
}

class ContentError extends ContentState {
  final String message;

  const ContentError(this.message);

  @override
  List<Object> get props => [message];
}