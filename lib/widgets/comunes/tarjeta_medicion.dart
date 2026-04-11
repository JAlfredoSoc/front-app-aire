import 'package:flutter/material.dart';
import '../../modelos/sensor.dart';
import 'chip_estado.dart';
import 'indicador_dato.dart';

/// Tarjeta que muestra los datos de una medición (sensor).
/// Usada tanto en la vista del mapa como en estadísticas.
///
/// [etiquetaSecundaria] es el texto pequeño debajo del nombre de zona.
class TarjetaMedicion extends StatelessWidget {
  final Sensor sensor;
  final String etiquetaSecundaria;
  final IconData icono;

  const TarjetaMedicion({
    super.key,
    required this.sensor,
    this.etiquetaSecundaria = 'Medición registrada',
    this.icono = Icons.pin_drop_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sensor.colorEstado.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sensor.colorEstado.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: sensor.colorEstado.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: sensor.colorEstado, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.zona,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      etiquetaSecundaria,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              ChipEstado(sensor: sensor),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              IndicadorDato(
                icono: Icons.co2_rounded,
                etiqueta: 'CO₂',
                valor: '${sensor.co2.toStringAsFixed(0)} ppm',
                color: const Color(0xFF00C9A7),
              ),
              const SizedBox(width: 8),
              IndicadorDato(
                icono: Icons.blur_on_rounded,
                etiqueta: 'PM2.5',
                valor: '${sensor.pm25.toStringAsFixed(1)} µg/m³',
                color: const Color(0xFFFFC857),
              ),
              const SizedBox(width: 8),
              IndicadorDato(
                icono: Icons.thermostat_rounded,
                etiqueta: 'Temp.',
                valor: '${sensor.temperatura.toStringAsFixed(1)} °C',
                color: const Color(0xFF7CC6FE),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
