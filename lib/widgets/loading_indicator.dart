import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:roomix/constants/app_colors.dart';

enum LoadingSize { small, medium, large }
enum LoadingStyle { standard, gradient, glass }

class LoadingIndicator extends StatefulWidget {
  final double? size;
  final Color? color;
  final LoadingSize sizeVariant;
  final LoadingStyle style;
  final bool showLabel;
  final String? label;

  const LoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.sizeVariant = LoadingSize.medium,
    this.style = LoadingStyle.gradient,
    this.showLabel = false,
    this.label,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  double _getSizeValue() {
    return widget.size ?? _getDefaultSize();
  }

  double _getDefaultSize() {
    switch (widget.sizeVariant) {
      case LoadingSize.small:
        return 30;
      case LoadingSize.medium:
        return 45;
      case LoadingSize.large:
        return 65;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = _getSizeValue();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        switch (widget.style) {
          LoadingStyle.standard => _buildStandardIndicator(size),
          LoadingStyle.gradient => _buildGradientIndicator(size),
          LoadingStyle.glass => _buildGlassIndicator(size),
        },
        if (widget.showLabel && widget.label != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.label!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStandardIndicator(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? const Color(0xFF8B5CF6),
        ),
        strokeWidth: size > 50 ? 4 : 3,
      ),
    );
  }

  Widget _buildGradientIndicator(double size) {
    return RotationTransition(
      turns: _rotationController,
      child: CustomPaint(
        size: Size(size, size),
        painter: _GradientSpinnerPainter(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFFEC4899),
              Color(0xFFF59E0B),
              Color(0xFF8B5CF6),
            ],
          ),
          strokeWidth: size > 50 ? 4 : 3,
        ),
      ),
    );
  }

  Widget _buildGlassIndicator(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2 + 12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: size + 24,
          height: size + 24,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(size / 2 + 12),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: RotationTransition(
              turns: _rotationController,
              child: CustomPaint(
                size: Size(size, size),
                painter: _GradientSpinnerPainter(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                      Color(0xFFF59E0B),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  strokeWidth: size > 50 ? 4 : 3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientSpinnerPainter extends CustomPainter {
  final LinearGradient gradient;
  final double strokeWidth;

  _GradientSpinnerPainter({
    required this.gradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Create shader for gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final shader = gradient.createShader(rect);

    final paint = Paint()
      ..shader = shader
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw arc (270 degrees = 75% circle)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start at top
      4.71239, // 270 degrees
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientSpinnerPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
