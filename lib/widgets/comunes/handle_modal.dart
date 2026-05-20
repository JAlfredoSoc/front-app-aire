import 'package:flutter/material.dart';

/// Handle visual para bottom sheets (barra gris centrada en la parte superior).
class HandleModal extends StatelessWidget {
  const HandleModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.20)
              : Colors.black.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
