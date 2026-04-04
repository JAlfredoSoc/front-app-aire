import 'package:flutter/material.dart';
import '../../../modelos/sensor.dart';

/// Tarjetas dinámicas que muestran los datos del sensor seleccionado
/// o el promedio general si no hay ninguno seleccionado.
class TarjetasSensor extends StatelessWidget {
  final Sensor? sensor;
  final bool esSensorSeleccionado;

  const TarjetasSensor({
    super.key,
    required this.sensor,
    required this.esSensorSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    if (sensor == null) {
      return const SizedBox.shrink();
    }

    final s = sensor!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(s.id),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: zona + estado
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.zona,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _ChipEstado(sensor: s),
              ],
            ),
            if (!esSensorSeleccionado)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  'Promedio de todos los puntos medidos',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            const SizedBox(height: 12),
            // Indicadores
            Row(
              children: [
                _IndicadorDato(
                  icono: Icons.co2_rounded,
                  etiqueta: 'CO₂',
                  valor: '${s.co2.toStringAsFixed(0)} ppm',
                  color: const Color(0xFF00C9A7),
                ),
                const SizedBox(width: 10),
                _IndicadorDato(
                  icono: Icons.blur_on_rounded,
                  etiqueta: 'PM2.5',
                  valor: '${s.pm25.toStringAsFixed(1)} µg/m³',
                  color: const Color(0xFFFFC857),
                ),
                const SizedBox(width: 10),
                _IndicadorDato(
                  icono: Icons.thermostat_rounded,
                  etiqueta: 'Temp.',
                  valor: '${s.temperatura.toStringAsFixed(1)} °C',
                  color: const Color(0xFF7CC6FE),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipEstado extends StatelessWidget {
  final Sensor sensor;

  const _ChipEstado({required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: sensor.colorEstado.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: sensor.colorEstado.withValues(alpha: 0.40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
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
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicadorDato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color color;

  const _IndicadorDato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              etiqueta,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
