import 'package:equatable/equatable.dart';

class Invitation extends Equatable {
  const Invitation({
    required this.id,
    required this.organizationId,
    required this.email,
    required this.role,
    required this.status,
    required this.invitedBy,
    required this.createdAt,
  });

  final String id;
  final String organizationId;
  final String email;
  final String role;
  final String status;
  final String invitedBy;
  final DateTime createdAt;

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      invitedBy: json['invited_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'email': email,
      'role': role,
      'status': status,
      'invited_by': invitedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        organizationId,
        email,
        role,
        status,
        invitedBy,
        createdAt,
      ];
}
