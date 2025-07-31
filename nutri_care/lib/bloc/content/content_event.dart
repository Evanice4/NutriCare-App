import 'package:equatable/equatable.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object> get props => [];
}

class LoadGuides extends ContentEvent {}

class LoadRecipes extends ContentEvent {}

class LoadAlerts extends ContentEvent {}

class RefreshContent extends ContentEvent {}