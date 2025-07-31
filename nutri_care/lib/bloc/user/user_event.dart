import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends UserEvent {
  final String uid;

  const LoadUserProfile(this.uid);

  @override
  List<Object> get props => [uid];
}

class SignOutUser extends UserEvent {}

class UpdateUserProfile extends UserEvent {
  final Map<String, dynamic> updates;

  const UpdateUserProfile(this.updates);

  @override
  List<Object> get props => [updates];
}