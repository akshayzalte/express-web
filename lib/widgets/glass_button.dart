import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'glass_container.dart';

class GlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? label;
  final bool isPrimary;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final IconData? icon;

  const GlassButton({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.isPrimary = true,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
    this.icon,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors
    final Color buttonColor = widget.isPrimary
        ? (isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary)
        : Colors.transparent;
        
    final Color textColor = widget.isPrimary
        ? Colors.white
        : (isDark ? Colors.white : GlacierColors.lightPrimary);

    Widget innerChild = widget.child ?? Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: textColor, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
        ),
      ],
    );

    Widget buttonBody;
    if (widget.isPrimary) {
      buttonBody = Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: innerChild,
      );
    } else {
      // Secondary is Glass style
      buttonBody = GlassContainer(
        padding: widget.padding,
        borderRadius: widget.borderRadius,
        customBgColor: isDark 
            ? Colors.white.withOpacity(0.06) 
            : Colors.white.withOpacity(0.4),
        child: Center(child: innerChild),
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: buttonBody,
      ),
    );
  }
}
