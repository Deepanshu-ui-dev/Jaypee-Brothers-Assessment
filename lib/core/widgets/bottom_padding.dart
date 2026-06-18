import 'package:flutter/material.dart';

class BottomPadding extends StatelessWidget {
  const BottomPadding({super.key, this.minimum = 16.0});

  final double minimum;

  static double of(BuildContext context, {double minimum = 16.0}) {
    final viewPadding = MediaQuery.viewPaddingOf(context).bottom;
    return viewPadding > minimum ? viewPadding : minimum;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: of(context, minimum: minimum));
  }
}
