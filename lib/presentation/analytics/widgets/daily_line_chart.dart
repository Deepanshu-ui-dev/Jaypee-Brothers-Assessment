import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../providers/transaction_provider.dart';

class DailyLineChart extends ConsumerWidget {
  const DailyLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyData = ref.watch(dailySpendingProvider);
    final now = DateTime.now();

    // Filter to only days up to today
    final pastDays = dailyData.where((d) => (d['day'] as int) <= now.day).toList();
    if (pastDays.isEmpty) {
      return const Center(child: Text('No spending data yet.'));
    }

    final maxY = pastDays.fold(0.0, (max, d) => (d['amount'] as double) > max ? (d['amount'] as double) : max);
    
    // We want a little padding at the top of the chart so the highest peak isn't clipped
    final topBound = maxY == 0 ? 100.0 : maxY * 1.2;

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: now.day.toDouble(),
          minY: 0,
          maxY: topBound,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => context.colors.ink,
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.y.asCurrency,
                    context.textStyles.bodyMedium.copyWith(color: context.colors.onInk),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: topBound > 0 ? topBound / 4 : 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colors.divider.withAlpha(50),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Y axis numbers to save space
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: now.day > 15 ? 5 : 2, // show every 5 days or 2 days depending on month progress
                getTitlesWidget: (value, meta) {
                  if (value == now.day.toDouble() || value == 1.0 || value % (now.day > 15 ? 5 : 2) == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(value.toInt().toString(), style: context.textStyles.caption),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 22,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: pastDays.map((d) => FlSpot((d['day'] as int).toDouble(), d['amount'] as double)).toList(),
              isCurved: true,
              color: context.colors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    context.colors.primary.withAlpha(80),
                    context.colors.primary.withAlpha(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
