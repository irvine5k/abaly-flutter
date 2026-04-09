import 'package:equatable/equatable.dart';

class AiSummary extends Equatable {
  const AiSummary({
    required this.id,
    required this.sessionId,
    required this.summary,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String summary;
  final DateTime createdAt;

  factory AiSummary.fromJson(Map<String, dynamic> json) {
    return AiSummary(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      summary: json['summary'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'summary': summary,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, sessionId, summary, createdAt];
}
