import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:roomix/constants/app_colors.dart';

enum ButtonStyle { solid, gradient, glass, outlined }

class CustomButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color color;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final ButtonStyle buttonStyle;
  final Color? gradientStart;
  final Color? gradientEnd;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color = AppColors.primary,
    this.textColor,
    this.borderColor,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
    this.padding,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.buttonStyle = ButtonStyle.solid,
    this.gradientStart,
    this.gradientEnd,
    this.icon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.onPressed != null) {
            _controller.forward();
          }
        },
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () {
          _controller.reverse();
        },
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: _buildButton(),
        ),
      ),
    );
  }

  Widget _buildButton() {
    switch (widget.buttonStyle) {
      case ButtonStyle.gradient:
        return _buildGradientButton();
      case ButtonStyle.glass:
        return _buildGlassButton();
      case ButtonStyle.outlined:
        return _buildOutlinedButton();
      case ButtonStyle.solid:
      default:
        return _buildSolidButton();
    }
  }

  Widget _buildSolidButton() {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color,
        foregroundColor: widget.textColor ?? (widget.color == Colors.white ? AppColors.textDark : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius!),
          side: widget.borderColor != null 
            ? BorderSide(color: widget.borderColor!, width: 1.5) 
            : BorderSide.none,
        ),
        elevation: 0,
        padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 12),
        shadowColor: Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon),
            const SizedBox(width: 8),
          ],
          Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius!),
        gradient: LinearGradient(
          colors: [
            widget.gradientStart ?? const Color(0xFF8B5CF6),
            widget.gradientEnd ?? const Color(0xFFEC4899),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.gradientStart ?? const Color(0xFF8B5CF6)).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(widget.borderRadius!),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: widget.fontWeight,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius!),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius!),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            color: Colors.white.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          fontWeight: widget.fontWeight,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius!),
        border: Border.all(
          color: widget.borderColor ?? widget.color,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(widget.borderRadius!),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.color),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: widget.fontWeight,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}