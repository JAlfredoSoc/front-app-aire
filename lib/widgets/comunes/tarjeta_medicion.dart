import 'package:flutter/material.dart';
import '../../modelos/sensor.dart';
import '../../core/tema/colores.dart';
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
    final theme = Theme.of(context);
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
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      etiquetaSecundaria,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
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
                color: AppColores.verde,
              ),
              const SizedBox(width: 8),
              IndicadorDato(
                icono: Icons.blur_on_rounded,
                etiqueta: 'PM2.5',
                valor: '${sensor.pm25.toStringAsFixed(1)} µg/m³',
                color: AppColores.amarillo,
              ),
              const SizedBox(width: 8),
              IndicadorDato(
                icono: Icons.thermostat_rounded,
                etiqueta: 'Temp.',
                valor: '${sensor.temperatura.toStringAsFixed(1)} °C',
                color: AppColores.azul,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
