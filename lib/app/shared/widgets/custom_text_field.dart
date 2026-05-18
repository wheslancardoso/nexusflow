import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? icon;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool isGlass;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.inputFormatters,
    this.maxLines = 1,
    this.isGlass = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isGlass) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isPassword,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: icon != null ? Icon(icon, color: Colors.white60, size: 18) : null,
            filled: true,
            fillColor: Colors.transparent,
            border: const OutlineInputBorder(borderSide: BorderSide.none),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
            errorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );
    }

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
