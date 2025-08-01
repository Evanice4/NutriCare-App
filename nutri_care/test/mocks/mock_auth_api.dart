import 'package:nutri_care/api/auth_api.dart';
import 'package:nutri_care/models/user_model.dart';

class MockAuthApi implements AuthApi {
  bool _shouldSucceed = true;
  UserProfile? _mockUser;

  void setShouldSucceed(bool shouldSucceed) {
    _shouldSucceed = shouldSucceed;
  }

  void setMockUser(UserProfile? user) {
    _mockUser = user;
  }

  @override
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_shouldSucceed) {
      return AuthResult(
        success: false,
        message: 'Login failed',
        user: null,
      );
    }

    return AuthResult(
      success: true,
      message: 'Login successful',
      user: _mockUser ?? const UserProfile(
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
      ),
    );
  }

  @override
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String userType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_shouldSucceed) {
      return AuthResult(
        success: false,
        message: 'Registration failed',
        user: null,
      );
    }

    return AuthResult(
      success: true,
      message: 'Registration successful',
      user: UserProfile(
        uid: 'new-user-uid',
        email: email,
        displayName: displayName,
        userType: userType,
        role: 'user',
        isVerified: false,
        certificateUrl: '',
        createdAt: DateTime.now().toIso8601String(),
        lastLoginAt: DateTime.now().toIso8601String(),
        isActive: true,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!_shouldSucceed) {
      throw Exception('Sign out failed');
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_shouldSucceed) {
      throw Exception('Failed to get user profile');
    }

    return _mockUser;
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_shouldSucceed) {
      throw Exception('Password reset failed');
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_shouldSucceed) {
      onError('Phone verification failed');
      return;
    }

    onCodeSent('test-verification-id');
  }

  @override
  Future<AuthResult> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_shouldSucceed || otp != '123456') {
      return AuthResult(
        success: false,
        message: 'Invalid OTP',
        user: null,
      );
    }

    return AuthResult(
      success: true,
      message: 'OTP verified successfully',
      user: _mockUser ?? const UserProfile(
        uid: 'phone-user-uid',
        email: '',
        displayName: 'Phone User',
        userType: 'member',
        role: 'user',
        isVerified: true,
        certificateUrl: '',
        createdAt: '2024-01-01',
        lastLoginAt: '2024-01-01',
        isActive: true,
      ),
    );
  }
}