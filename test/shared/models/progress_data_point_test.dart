import 'package:abaly/shared/models/progress_data_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgressDataPoint', () {
    test('equality based on sessionDate and value', () {
      final date = DateTime.utc(2024, 6, 15);
      final point1 = ProgressDataPoint(sessionDate: date, value: 42.0);
      final point2 = ProgressDataPoint(sessionDate: date, value: 42.0);
      final point3 = ProgressDataPoint(sessionDate: date, value: 50.0);

      expect(point1, equals(point2));
      expect(point1, isNot(equals(point3)));
    });

    test('props include all fields', () {
      final date = DateTime.utc(2024, 6, 15);
      final point = ProgressDataPoint(sessionDate: date, value: 80.0);

      expect(point.props, [date, 80.0]);
    });
  });
}
