import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../providers/transaction_provider.dart';

class DailyLineChart extends ConsumerStatefulWidget {
  const DailyLineChart({super.key});

  @override
  ConsumerState<DailyLineChart> createState() => _DailyLineChartState();
}

class _DailyLineChartState extends ConsumerState<DailyLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailyData = ref.watch(dailySpendingProvider);
    final now = DateTime.now();

    // Filter to only days up to today
    final pastDays = dailyData.where((d) => (d['day'] as int) <= now.day).toList();
    if (pastDays.isEmpty) {
      return const Center(child: Text('No data yet.'));
    }

    final maxExp = pastDays.fold(0.0, (m, d) => (d['amount'] as double) > m ? (d['amount'] as double) : m);
    final maxInc = pastDays.fold(0.0, (m, d) => (d['income'] as double) > m ? (d['income'] as double) : m);
    final maxY = maxExp > maxInc ? maxExp : maxInc;
    final topBound = maxY == 0 ? 100.0 : maxY * 1.25;

    final incomeColor = const Color(0xFF34D399); // Green
    final expenseColor = const Color(0xFFFF6B6B); // Red

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final progress = _anim.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chart Legend
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(incomeColor, 'Earned'),
                  const SizedBox(width: 24),
                  _buildLegendItem(expenseColor, 'Spent'),
                ],
              ),
            ),
            AspectRatio(
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
                          final isIncome = spot.barIndex == 0;
                          return LineTooltipItem(
                            '${isIncome ? "Earned" : "Spent"}: ${spot.y.asCurrency}',
                            context.textStyles.bodyMedium.copyWith(
                              color: isIncome ? incomeColor : expenseColor,
                              fontWeight: FontWeight.w600,
                            ),
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
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: now.day > 15 ? 5 : 2,
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
                    // Income Bar (Index 0)
                    _buildLineBar(
                      pastDays,
                      color: incomeColor,
                      progress: progress,
                      valueKey: 'income',
                    ),
                    // Expense Bar (Index 1)
                    _buildLineBar(
                      pastDays,
                      color: expenseColor,
                      progress: progress,
                      valueKey: 'amount',
                    ),
                  ],
                ),
                duration: Duration.zero,
              ),
            ),
          ],
        );
      },
    );
  }

  LineChartBarData _buildLineBar(List<Map<String, dynamic>> pastDays,
      {required Color color, required double progress, required String valueKey}) {
    final spots = pastDays.map((d) {
      final y = d[valueKey] as double;
      // Animate Y value upwards
      return FlSpot((d['day'] as int).toDouble(), y * progress);
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 3.5,
      isStrokeCapRound: true,
      shadow: Shadow(
        color: color.withAlpha(120),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, pct, bar, idx) {
          if (idx != spots.length - 1) {
            return FlDotCirclePainter(radius: 0, color: Colors.transparent);
          }
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withAlpha(80),
            color.withAlpha(20),
            color.withAlpha(0),
          ],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(120),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
