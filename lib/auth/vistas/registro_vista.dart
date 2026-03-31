import 'package:flutter/material.dart';

class RegistroVista extends StatelessWidget {
  const RegistroVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: const Center(
        child: Text("Pantalla de Registro"),
      ),
    );
  }
}