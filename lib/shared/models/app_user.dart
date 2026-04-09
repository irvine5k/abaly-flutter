import 'package:equatable/equatable.dart';

enum UserRole {
  admin,
  therapist;

  factory UserRole.fromJson(String value) {
    return switch (value) {
      'admin' => UserRole.admin,
      'therapist' => UserRole.therapist,
      _ => throw ArgumentError('Unknown UserRole: $value'),
    };
  }

  String toJson() {
    return switch (this) {
      UserRole.admin => 'admin',
      UserRole.therapist => 'therapist',
    };
  }
}

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.organizationId,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String organizationId;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: UserRole.fromJson(json['role'] as String),
      organizationId: json['organization_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.toJson(),
      'organization_id': organizationId,
    };
  }

  @override
  List<Object?> get props => [id, email, fullName, role, organizationId];
}
