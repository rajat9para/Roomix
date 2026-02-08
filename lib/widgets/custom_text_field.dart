import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:roomix/constants/app_colors.dart';

enum TextFieldStyle { solid, glass }

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLength;
  final int? maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final TextFieldStyle style;
  final Color? fillColor;
  final Color? labelColor;
  final Color? iconColor;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onTap,
    this.margin,
    this.padding,
    this.style = TextFieldStyle.solid,
    this.fillColor,
    this.labelColor,
    this.iconColor,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      padding: widget.padding ?? EdgeInsets.zero,
      child: widget.style == TextFieldStyle.glass
          ? _buildGlassTextField()
          : _buildSolidTextField(),
    );
  }

  Widget _buildSolidTextField() {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      focusNode: _focusNode,
      enabled: widget.enabled,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: (widget.labelText?.isNotEmpty ?? false) ? widget.labelText : null,
        hintText: widget.hintText,
        labelStyle: TextStyle(
          color: widget.labelColor ?? AppColors.textGray,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textSubtle,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          widget.icon,
          color: widget.iconColor ?? AppColors.primary,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        fillColor: widget.fillColor ?? Colors.white,
        filled: true,
        counterText: widget.maxLength != null ? null : '',
      ),
      validator: widget.validator,
    );
  }

  Widget _buildGlassTextField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          focusNode: _focusNode,
          enabled: widget.enabled,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: (widget.labelText?.isNotEmpty ?? false) ? widget.labelText : null,
            hintText: widget.hintText,
            labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF8B5CF6).withOpacity(0.8),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.withOpacity(0.8),
                width: 2,
              ),
            ),
            fillColor: Colors.white.withOpacity(0.08),
            filled: true,
            counterText: widget.maxLength != null ? null : '',
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}
