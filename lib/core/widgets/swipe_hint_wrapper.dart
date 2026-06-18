import 'package:flutter/material.dart';
import '../../data/local/hive_service.dart';

class SwipeHintWrapper extends StatefulWidget {
  const SwipeHintWrapper({
    super.key,
    required this.child,
    required this.hintKey,
  });

  final Widget child;
  final String hintKey;

  @override
  State<SwipeHintWrapper> createState() => _SwipeHintWrapperState();
}

class _SwipeHintWrapperState extends State<SwipeHintWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    _checkAndAnimate();
  }

  void _checkAndAnimate() {
    final hasSeen = HiveService.settings.get('seen_swipe_hint_${widget.hintKey}') as bool? ?? false;
    if (hasSeen) return;

    _shouldAnimate = true;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _anim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -30.0).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -30.0, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 70),
    ]).animate(_ctrl);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _ctrl.forward();
        HiveService.settings.put('seen_swipe_hint_${widget.hintKey}', true);
      }
    });
  }

  @override
  void dispose() {
    if (_shouldAnimate) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldAnimate) return widget.child;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_anim.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
