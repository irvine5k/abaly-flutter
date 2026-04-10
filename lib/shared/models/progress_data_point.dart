import 'package:equatable/equatable.dart';

class ProgressDataPoint extends Equatable {
  const ProgressDataPoint({
    required this.sessionDate,
    required this.value,
  });

  /// The date the session was completed.
  final DateTime sessionDate;

  /// For frequency: raw count. For percentage: 0–100.
  final double value;

  @override
  List<Object?> get props => [sessionDate, value];
}
