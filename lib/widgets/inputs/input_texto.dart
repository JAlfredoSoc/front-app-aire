import 'package:flutter/material.dart';
import '../../core/tema/colores.dart';

class InputTexto extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool esPassword;

  const InputTexto({
    super.key,
    required this.controller,
    required this.hint,
    this.esPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return TextField(
      controller: controller,
      obscureText: esPassword,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColores.verde,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
