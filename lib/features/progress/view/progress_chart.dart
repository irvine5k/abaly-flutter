import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../shared/models/progress_data_point.dart';
import '../../../shared/models/template_field.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({
    super.key,
    required this.dataPoints,
    required this.fieldType,
  });

  final List<ProgressDataPoint> dataPoints;
  final FieldType fieldType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final spots = dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final maxY = fieldType == FieldType.percentage
        ? 100.0
        : (dataPoints
                    .map((p) => p.value)
                    .fold<double>(0, (a, b) => a > b ? a : b) *
                1.2)
            .ceilToDouble()
            .clamp(5.0, double.infinity);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: fieldType == FieldType.percentage
                    ? 25
                    : (maxY / 4).ceilToDouble().clamp(1, double.infinity),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: _bottomInterval,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= dataPoints.length) {
                        return const SizedBox.shrink();
                      }
                      final date = dataPoints[index].sessionDate;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${date.month}/${date.day}',
                          style: theme.textTheme.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: fieldType == FieldType.percentage
                        ? 25
                        : (maxY / 4)
                            .ceilToDouble()
                            .clamp(1, double.infinity),
                    getTitlesWidget: (value, meta) {
                      final label = fieldType == FieldType.percentage
                          ? '${value.toInt()}%'
                          : value.toInt().toString();
                      return Text(
                        label,
                        style: theme.textTheme.labelSmall,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (dataPoints.length - 1).toDouble().clamp(0, double.infinity),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: primaryColor,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: primaryColor,
                      strokeWidth: 2,
                      strokeColor: theme.colorScheme.surface,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: primaryColor.withValues(alpha: 0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final index = spot.x.toInt();
                      final point = dataPoints[index];
                      final date = point.sessionDate;
                      final valueLabel = fieldType == FieldType.percentage
                          ? '${point.value.toStringAsFixed(0)}%'
                          : point.value.toStringAsFixed(0);
                      return LineTooltipItem(
                        '$valueLabel\n${date.month}/${date.day}/${date.year}',
                        TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double get _bottomInterval {
    if (dataPoints.length <= 7) return 1;
    return (dataPoints.length / 6).ceilToDouble();
  }
}
