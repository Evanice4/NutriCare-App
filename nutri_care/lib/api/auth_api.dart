import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Login with email and password
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure('Email and password are required');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user == null) {
        return AuthResult.failure('Login failed. Please try again.');
      }

      // Get user profile
      final userProfile = await getUserProfile(credential.user!.uid);
      if (userProfile == null) {
        return AuthResult.failure('User profile not found. Please contact support.');
      }

      // Update last login time
      try {
        final updatedProfile = userProfile.copyWith(lastLoginAt: DateTime.now());
        await updateUserProfile(updatedProfile);
      } catch (updateError) {
        // Continue even if update fails
        print('Profile update failed: $updateError');
      }

      return AuthResult.success(userProfile);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Register user
  Future<AuthResult> registerUser({
    required String email,
    required String password,
    required String displayName,
    required String userType,
    String? certificateUrl,
  }) async {
    try {
      print('Starting registration for: $email');
      
      // Validate inputs
      if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
        return AuthResult.failure('All fields are required');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }

      print('Creating Firebase Auth user...');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user == null) {
        return AuthResult.failure('Registration failed. Please try again.');
      }

      print('Firebase Auth user created: ${credential.user!.uid}');

      // Update Firebase Auth display name
      await credential.user!.updateDisplayName(displayName.trim());

      // Create user profile
      final userProfile = UserProfile(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        userType: userType,
        role: userType == 'creator' ? 'creator' : 'member',
        isVerified: userType != 'creator', // Members are auto-verified, creators need admin approval
        certificateUrl: certificateUrl,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Save to Firestore
      try {
        print('Saving user profile to Firestore...');
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userProfile.toMap());
        print('User profile saved successfully');
      } catch (firestoreError) {
        print('Firestore error: $firestoreError');
        // Clean up auth user if Firestore fails
        try {
          await credential.user!.delete();
        } catch (_) {}
        return AuthResult.failure('Database permission error. Please check your Firebase Firestore security rules.');
      }

      print('Registration completed successfully');
      return AuthResult.success(userProfile);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      print('General registration error: $e');
      return AuthResult.failure('Registration error: ${e.toString()}');
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromMap(uid, doc.data()!);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserProfile userProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userProfile.uid)
          .update(userProfile.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Phone authentication
  Future<AuthResult> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _signInWithPhoneCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_getFirebaseAuthErrorMessage(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure('Phone verification failed: ${e.toString()}');
    }
  }

  // Verify OTP and sign in
  Future<AuthResult> verifyOTPAndSignIn({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _signInWithPhoneCredential(credential);
    } catch (e) {
      return AuthResult.failure('Invalid OTP. Please try again.');
    }
  }

  // Helper method for phone credential sign-in
  Future<AuthResult> _signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        return AuthResult.failure('Sign-in failed. Please try again.');
      }

      // Check if user profile exists
      UserProfile? userProfile = await getUserProfile(userCredential.user!.uid);
      
      if (userProfile == null) {
        // Create new user profile for phone authentication
        userProfile = UserProfile(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? 'Phone User',
          userType: 'member',
          role: 'member',
          isVerified: true,
          phoneNumber: userCredential.user!.phoneNumber,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userProfile.toMap());
      } else {
        // Update last login time
        final updatedProfile = userProfile.copyWith(lastLoginAt: DateTime.now());
        await updateUserProfile(updatedProfile);
      }

      return AuthResult.success(userProfile);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Sign-in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      // Delete user profile from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();

      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Private helper methods
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

// Auth result wrapper class
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserProfile? user;

  AuthResult._({required this.isSuccess, this.errorMessage, this.user});

  factory AuthResult.success(UserProfile? user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}
