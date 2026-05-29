import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? customBgColor;
  final Color? customBorderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.width,
    this.height,
    this.customBgColor,
    this.customBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color bgColor = customBgColor ?? 
        (isDark ? GlacierColors.darkSurface : GlacierColors.lightSurface);
        
    final Color borderColor = customBorderColor ?? 
        (isDark ? GlacierColors.darkBorder : GlacierColors.lightBorder);

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
