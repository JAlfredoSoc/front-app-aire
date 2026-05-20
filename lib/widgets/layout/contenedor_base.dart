import 'package:flutter/material.dart';
import '../../core/tema/colores.dart';

class ContenedorBase extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ContenedorBase({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColores.gradienteFondoOscuro : AppColores.gradienteFondoClaro,
        ),
        child: SafeArea(
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
