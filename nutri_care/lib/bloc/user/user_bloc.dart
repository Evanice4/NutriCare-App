import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/auth_api.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthApi _authApi = AuthApi();

  UserBloc() : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<SignOutUser>(_onSignOutUser);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await _authApi.getUserProfile(event.uid);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const UserError('User profile not found'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onSignOutUser(
    SignOutUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _authApi.signOut();
      emit(UserSignedOut());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      emit(UserLoading());
      try {
        // Update user profile logic would go here
        emit(UserLoaded(currentUser));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    }
  }
}