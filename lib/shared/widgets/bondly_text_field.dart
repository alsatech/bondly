import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Bondly text field — underline-only style matching the auth design reference.
/// No filled background, just a clean bottom border.
class BondlyTextField extends StatefulWidget {
  const BondlyTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.autofocus = false,
    this.prefixText,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final int maxLines;
  final bool autofocus;
  final String? prefixText;

  @override
  State<BondlyTextField> createState() => _BondlyTextFieldState();
}

class _BondlyTextFieldState extends State<BondlyTextField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      autofocus: widget.autofocus,
      style: GoogleFonts.dmSans(
        fontSize: 15,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      cursorColor: AppColors.gold,
      decoration: InputDecoration(
        // Uppercase spaced label
        labelText: widget.label,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1.4,
        ),
        floatingLabelStyle: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
          letterSpacing: 1.4,
        ),
        hintText: widget.hint,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 15,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        prefixText: widget.prefixText,
        prefixStyle: GoogleFonts.dmSans(
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
        prefixIcon: widget.prefixIcon != null
            ? IconTheme(
                data: const IconThemeData(color: AppColors.textSecondary, size: 18),
                child: widget.prefixIcon!,
              )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              )
            : (widget.suffixIcon != null
                ? IconTheme(
                    data: const IconThemeData(color: AppColors.textSecondary, size: 18),
                    child: widget.suffixIcon!,
                  )
                : null),
        // Underline-only — no filled box
        filled: false,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 1.0),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.gold, width: 1.0),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1.0),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.only(top: 12, bottom: 10),
        errorStyle: GoogleFonts.dmSans(
          fontSize: 11,
          color: AppColors.primary,
        ),
        isDense: true,
      ),
    );
  }
}
