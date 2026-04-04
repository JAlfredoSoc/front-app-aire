import 'package:flutter/material.dart';
import '../../../modelos/sensor.dart';

/// Marcador interactivo que se muestra sobre el mapa para cada sensor.
/// Cambia de color y tamaño según el estado y si está seleccionado.
class MarcadorSensor extends StatelessWidget {
  final Sensor sensor;
  final bool seleccionado;
  final VoidCallback onTap;

  const MarcadorSensor({
    super.key,
    required this.sensor,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: seleccionado
              ? sensor.colorEstado.withValues(alpha: 0.25)
              : const Color(0xEE0B1821),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sensor.colorEstado.withValues(
              alpha: seleccionado ? 1.0 : 0.65,
            ),
            width: seleccionado ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: sensor.colorEstado.withValues(
                alpha: seleccionado ? 0.40 : 0.20,
              ),
              blurRadius: seleccionado ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pin_drop_outlined,
                  size: 12,
                  color: sensor.colorEstado,
                ),
                const SizedBox(width: 4),
                Text(
                  '${sensor.co2.toStringAsFixed(0)} ppm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sensor.zona,
              style: const TextStyle(color: Colors.white60, fontSize: 9),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
