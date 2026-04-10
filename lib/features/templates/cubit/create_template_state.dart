import 'package:equatable/equatable.dart';

import '../../../shared/models/template_field.dart';

enum CreateTemplateStatus { initial, loading, success, error }

class CreateTemplateState extends Equatable {
  const CreateTemplateState({
    this.fields = const [],
    this.status = CreateTemplateStatus.initial,
    this.error,
  });

  final List<TemplateField> fields;
  final CreateTemplateStatus status;
  final String? error;

  CreateTemplateState copyWith({
    List<TemplateField>? fields,
    CreateTemplateStatus? status,
    String? error,
  }) {
    return CreateTemplateState(
      fields: fields ?? this.fields,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [fields, status, error];
}
