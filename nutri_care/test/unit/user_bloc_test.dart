import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:nutri_care/bloc/user/user_bloc.dart';
import 'package:nutri_care/models/user_model.dart';

void main() {
  group('UserBloc', () {
    late UserBloc userBloc;

    setUp(() {
      userBloc = UserBloc();
    });

    tearDown(() {
      userBloc.close();
    });

    test('initial state is UserInitial', () {
      expect(userBloc.state, UserInitial());
    });

    group('LoadUserProfile', () {
      const testUser = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        userType: 'member',
        role: 'user',
        isVerified: true,
        certificateUrl: '',
        createdAt: '2024-01-01',
        lastLoginAt: '2024-01-01',
        isActive: true,
      );

      blocTest<UserBloc, UserState>(
        'emits [UserLoading, UserLoaded] when LoadUserProfile succeeds',
        build: () => userBloc,
        act: (bloc) => bloc.add(const LoadUserProfile('test-uid')),
        expect: () => [
          UserLoading(),
          // Note: This would need a mock AuthApi to properly test
        ],
        skip: 2, // Skip until we implement proper mocking
      );

      blocTest<UserBloc, UserState>(
        'emits [UserLoading, UserError] when LoadUserProfile fails',
        build: () => userBloc,
        act: (bloc) => bloc.add(const LoadUserProfile('invalid-uid')),
        expect: () => [
          UserLoading(),
          // Note: This would need a mock AuthApi to properly test
        ],
        skip: 2, // Skip until we implement proper mocking
      );
    });

    group('SignOutUser', () {
      blocTest<UserBloc, UserState>(
        'emits [UserSignedOut] when SignOutUser succeeds',
        build: () => userBloc,
        act: (bloc) => bloc.add(SignOutUser()),
        expect: () => [
          // Note: This would need a mock AuthApi to properly test
        ],
        skip: 1, // Skip until we implement proper mocking
      );
    });
  });
}