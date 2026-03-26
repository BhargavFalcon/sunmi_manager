import 'package:flutter/material.dart';

enum PulseStyle { blink, fill }

class PulsingWidget extends StatefulWidget {
  final Widget child;
  final bool isPulsing;
  final PulseStyle pulseStyle;
  final Color? pulsingColor;
  final double borderRadius;

  const PulsingWidget({
    super.key,
    required this.child,
    required this.isPulsing,
    this.pulseStyle = PulseStyle.blink,
    this.pulsingColor,
    this.borderRadius = 8,
  });

  @override
  State<PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulsingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPulsing) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final reverseVal = 1.0 - _animation.value;
        
        if (widget.pulseStyle == PulseStyle.fill) {
          // Fill style: pulsing background color, no shadow
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: (widget.pulsingColor ?? Colors.red).withOpacity(
                reverseVal * 0.6, // Strong fill
              ),
            ),
            child: Opacity(
              opacity: 0.8 + (_animation.value * 0.2),
              child: widget.child,
            ),
          );
        } else {
          // Blink style: simple opacity change
          return Opacity(
            opacity: 0.3 + (_animation.value * 0.7),
            child: widget.child,
          );
        }
      },
      child: widget.child,
    );
  }
}
