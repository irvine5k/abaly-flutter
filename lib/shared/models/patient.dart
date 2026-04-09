import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  const Patient({
    required this.id,
    required this.fullName,
    this.dateOfBirth,
    required this.organizationId,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final DateTime? dateOfBirth;
  final String organizationId;
  final String createdBy;
  final DateTime createdAt;

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      organizationId: json['organization_id'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'organization_id': organizationId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        dateOfBirth,
        organizationId,
        createdBy,
        createdAt,
      ];
}
