import 'package:flutter/material.dart';
import '../widgets/formulario_login.dart';

class LoginVista extends StatelessWidget {
  const LoginVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            ),
          ),
          child: const SafeArea(child: FormularioLogin()),
        ),
      ),
    );
  }
}
