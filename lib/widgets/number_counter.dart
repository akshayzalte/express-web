import 'package:flutter/material.dart';

class NumberCounter extends StatefulWidget {
  final int targetValue;
  final TextStyle? style;
  final Duration duration;

  const NumberCounter({
    super.key,
    required this.targetValue,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<NumberCounter> createState() => _NumberCounterState();
}

class _NumberCounterState extends State<NumberCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.targetValue.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant NumberCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.targetValue.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _animation.value.round().toString(),
          style: widget.style,
        );
      },
    );
  }
}
