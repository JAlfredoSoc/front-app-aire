import 'package:flutter/material.dart';
import '../../modelos/sensor.dart';

/// Chip de color que muestra el estado de calidad del aire de un sensor.
class ChipEstado extends StatelessWidget {
  final Sensor sensor;

  const ChipEstado({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: sensor.colorEstado.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: sensor.colorEstado.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: sensor.colorEstado,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            sensor.etiquetaEstado,
            style: TextStyle(
              color: sensor.colorEstado,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
