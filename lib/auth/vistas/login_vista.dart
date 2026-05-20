import 'package:flutter/material.dart';
import '../widgets/formulario_login.dart';

class LoginVista extends StatelessWidget {
  const LoginVista({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final gradientColors = isDark
        ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
        : [const Color(0xFFF5FBFC), const Color(0xFFE8F4F8), const Color(0xFFD0EBF5)];
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F2027) : const Color(0xFFF5FBFC),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: const SafeArea(child: FormularioLogin()),
        ),
      ),
    );
  }
}
