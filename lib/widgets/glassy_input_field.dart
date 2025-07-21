import 'dart:ui';
import 'package:flutter/material.dart';

class GlassyInputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isPassword;

  const GlassyInputField({
    super.key,
    required this.icon,
    required this.hint,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withOpacity(0.2),
          ),
          child: TextField(
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white70),
              suffixIcon: isPassword ? const Icon(Icons.visibility_off, color: Colors.white70) : null,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.text,
            textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
          ),
        ),
      ),
    );
  }
}
