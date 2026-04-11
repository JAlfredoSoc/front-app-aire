import 'package:flutter/material.dart';

/// Handle visual para bottom sheets (barra gris centrada en la parte superior).
class HandleModal extends StatelessWidget {
  const HandleModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
