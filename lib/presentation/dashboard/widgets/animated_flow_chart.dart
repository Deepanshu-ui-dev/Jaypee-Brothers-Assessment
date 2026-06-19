import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/transaction_provider.dart';

class AnimatedFlowChart extends ConsumerStatefulWidget {
  const AnimatedFlowChart({super.key});

  @override
  ConsumerState<AnimatedFlowChart> createState() => _AnimatedFlowChartState();
}

class _AnimatedFlowChartState extends ConsumerState<AnimatedFlowChart> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isLoaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dailyNetBalanceProvider);
    final hasData = data.any((d) => d.net != 0);

    if (!hasData) {
      return _buildEmptySparkline();
    }

    final targetSpots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.net);
    }).toList();

    // Use zeros for initial state to trigger fluid FlChart animation
    final currentSpots = _isLoaded 
        ? targetSpots 
        : data.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), 0);
          }).toList();

    final maxY = targetSpots.map((s) => s.y).reduce(math.max);
    final minY = targetSpots.map((s) => s.y).reduce(math.min);
    
    final range = (maxY - minY).abs();
    final padding = range == 0 ? 100.0 : range * 0.2;
    
    final topBound = maxY + padding;
    final bottomBound = minY - padding;

    // Determine if overall trend is positive or negative
    final netSum = data.fold(0.0, (s, d) => s + d.net);
    final lineColor = netSum >= 0
        ? const Color(0xFF34D399)
        : const Color(0xFFFF6B6B);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 13,
        minY: bottomBound,
        maxY: topBound,
        lineBarsData: [
          LineChartBarData(
            spots: currentSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: lineColor,
            barWidth: 3.5,
            isStrokeCapRound: true,
            shadow: Shadow(
              color: lineColor.withAlpha(120),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, pct, bar, idx) {
                if (idx != targetSpots.length - 1) {
                  return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                }
                return FlDotCirclePainter(
                  radius: 4.5,
                  color: lineColor,
                  strokeWidth: 2.5,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  lineColor.withAlpha(100),
                  lineColor.withAlpha(30),
                  lineColor.withAlpha(0),
                ],
                stops: const [0.0, 0.6, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            aboveBarData: BarAreaData(
              show: netSum < 0,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B6B).withAlpha(0),
                  const Color(0xFFFF6B6B).withAlpha(30),
                  const Color(0xFFFF6B6B).withAlpha(100),
                ],
                stops: const [0.0, 0.4, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: Colors.white.withAlpha(40),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ],
        ),
      ),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildEmptySparkline() {
    return CustomPaint(
      painter: _DummySparklinePainter(),
    );
  }
}

class _DummySparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(60)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.7,
        size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.3,
        size.width, size.height * 0.4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
