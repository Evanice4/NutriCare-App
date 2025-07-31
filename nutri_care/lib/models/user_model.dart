import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String userType; // 'creator' or 'member'
  final String role; // 'creator', 'member', or 'admin'
  final bool isVerified;
  final String? certificateUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.userType,
    required this.role,
    required this.isVerified,
    this.certificateUrl,
    this.phoneNumber,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      userType: map['userType'] ?? 'member',
      role: map['role'] ?? 'member',
      isVerified: map['isVerified'] ?? false,
      certificateUrl: map['certificateUrl'],
      phoneNumber: map['phoneNumber'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
                DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null
          ? (map['lastLoginAt'] is Timestamp
                ? (map['lastLoginAt'] as Timestamp).toDate()
                : DateTime.tryParse(map['lastLoginAt'].toString()))
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'userType': userType,
      'role': role,
      'isVerified': isVerified,
      'certificateUrl': certificateUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'isActive': isActive,
    };
  }

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? userType,
    String? role,
    bool? isVerified,
    String? certificateUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      userType: userType ?? this.userType,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, userType: $userType, role: $role, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
