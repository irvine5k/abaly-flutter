import 'package:equatable/equatable.dart';

enum SessionStatus {
  pending,
  inProgress,
  completed;

  static SessionStatus fromString(String value) {
    switch (value) {
      case 'in_progress':
        return SessionStatus.inProgress;
      default:
        return SessionStatus.values.firstWhere(
          (e) => e.name == value,
        );
    }
  }

  String toJsonString() {
    switch (this) {
      case SessionStatus.inProgress:
        return 'in_progress';
      default:
        return name;
    }
  }
}

class Session extends Equatable {
  const Session({
    required this.id,
    required this.patientId,
    required this.templateId,
    required this.therapistId,
    required this.organizationId,
    required this.status,
    this.scheduledAt,
    this.completedAt,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String patientId;
  final String templateId;
  final String therapistId;
  final String organizationId;
  final SessionStatus status;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final String createdBy;
  final DateTime createdAt;

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      templateId: json['template_id'] as String,
      therapistId: json['therapist_id'] as String,
      organizationId: json['organization_id'] as String,
      status: SessionStatus.fromString(json['status'] as String),
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'template_id': templateId,
      'therapist_id': therapistId,
      'organization_id': organizationId,
      'status': status.toJsonString(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        templateId,
        therapistId,
        organizationId,
        status,
        scheduledAt,
        completedAt,
        createdBy,
        createdAt,
      ];
}
