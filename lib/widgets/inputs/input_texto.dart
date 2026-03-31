import 'package:flutter/material.dart';

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
    return TextField(
      controller: controller,
      obscureText: esPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
