import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/animated_number.dart';
import '../../../providers/transaction_provider.dart';


class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayExp = ref.watch(todayExpenseProvider);
    final yesterdayExp = ref.watch(yesterdayExpenseProvider);
    final topCat = ref.watch(topCategoryProvider);

    // Build the "vs yesterday" label from real data
    String vsYesterdayLabel;
    if (yesterdayExp <= 0 && todayExp <= 0) {
      vsYesterdayLabel = 'No spending today';
    } else if (yesterdayExp <= 0) {
      vsYesterdayLabel = 'First day of spending!';
    } else {
      final diff = todayExp - yesterdayExp;
      final pct = ((diff.abs() / yesterdayExp) * 100).toStringAsFixed(0);
      vsYesterdayLabel = diff >= 0
          ? '↑ $pct% higher than yesterday'
          : '↓ $pct% lower than yesterday';
    }


    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: context.colors.balanceCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period selector chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total Spent:  Today',
                              style: context.textStyles.caption
                                  .copyWith(color: Colors.white70, fontSize: 11),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.white70, size: 14),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedNumber(
                        number: todayExp,
                        style: context.textStyles.displayAmountWhite,
                        prefix: NumExtension.activeCurrencySymbol,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_outward_rounded,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              vsYesterdayLabel,
                              style: context.textStyles.label.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // Sparkline
                SizedBox(
                  width: 100,
                  height: 60,
                  child: CustomPaint(painter: _SparklinePainter()),
                )
              ],
            ),
          ),

          // Bottom Bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.star_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Category',
                          style: context.textStyles.label
                              .copyWith(color: Colors.white70)),
                      Text(
                        topCat ?? 'No expenses yet',
                        style: context.textStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                // Show top category amount if exists
                if (topCat != null)
                  Builder(builder: (context) {
                    final map = ref.watch(expenseByCategoryProvider);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        (map[topCat] ?? 0).asCurrency,
                        style: context.textStyles.label
                            .copyWith(color: Colors.white),
                      ),
                    );
                  })
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.9,
        size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.1,
        size.width * 0.8, size.height * 0.4);
    path.quadraticBezierTo(
        size.width * 0.9, size.height * 0.5, size.width, size.height * 0.1);

    canvas.drawPath(path, paint);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [Colors.white.withAlpha(60), Colors.white.withAlpha(0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width, size.height * 0.1), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
