import 'package:equatable/equatable.dart';
import '../../models/content_models.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object> get props => [];
}

class LoadGuides extends ContentEvent {}

class LoadRecipes extends ContentEvent {}

class LoadAlerts extends ContentEvent {}

class RefreshContent extends ContentEvent {}

class DeleteRecipe extends ContentEvent {
  final String recipeId;
  final String currentUserId;

  const DeleteRecipe({required this.recipeId, required this.currentUserId});

  @override
  List<Object> get props => [recipeId, currentUserId];
}

class DeleteGuide extends ContentEvent {
  final String guideId;
  final String currentUserId;

  const DeleteGuide({required this.guideId, required this.currentUserId});

  @override
  List<Object> get props => [guideId, currentUserId];
}

class UpdateRecipe extends ContentEvent {
  final Recipe recipe;
  final String currentUserId;

  const UpdateRecipe({required this.recipe, required this.currentUserId});

  @override
  List<Object> get props => [recipe, currentUserId];
}

class UpdateGuide extends ContentEvent {
  final Guide guide;
  final String currentUserId;

  const UpdateGuide({required this.guide, required this.currentUserId});

  @override
  List<Object> get props => [guide, currentUserId];
}