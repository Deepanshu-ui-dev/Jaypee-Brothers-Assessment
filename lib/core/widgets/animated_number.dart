import 'package:flutter/material.dart';

class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({
    super.key,
    required this.number,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
  });

  final double number;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;

  String _formatNumber(double val) {
    if (val == val.toInt()) {
      return val.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } else {
      return val.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: number),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Text(
          '$prefix${_formatNumber(value)}$suffix',
          style: style,
        );
      },
    );
  }
}
