import 'package:flutter/material.dart';

/// Contenido puro de la pantalla educativa.
/// Sin header ni navbar — los provee AppShell.
class EducacionContenido extends StatelessWidget {
  const EducacionContenido({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      children: const [
        _TarjetaCo2(),
        SizedBox(height: 14),
        _TarjetaParticulas(),
        SizedBox(height: 14),
        _TarjetaQueMide(),
        SizedBox(height: 14),
        _TarjetaSalud(),
        SizedBox(height: 14),
        _TarjetaValledupar(),
        SizedBox(height: 14),
        _TarjetaConsejos(),
      ],
    );
  }
}

// ── Base de tarjeta ───────────────────────────────────────────────────────────

class _Tarjeta extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Color colorAccento;
  final Widget cuerpo;

  const _Tarjeta({
    required this.icono,
    required this.titulo,
    required this.colorAccento,
    required this.cuerpo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: colorAccento.withValues(alpha: 0.09),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colorAccento.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icono, color: colorAccento, size: 19),
                ),
                const SizedBox(width: 12),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: cuerpo,
          ),
        ],
      ),
    );
  }
}

// ── Widgets reutilizables ─────────────────────────────────────────────────────

class _Parrafo extends StatelessWidget {
  final String texto;
  const _Parrafo(this.texto);
  @override
  Widget build(BuildContext context) => Text(
    texto,
    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.55),
  );
}

class _Fila extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;
  const _Fila({required this.icono, required this.color, required this.texto});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NivelBar extends StatelessWidget {
  final String etiqueta;
  final String rango;
  final Color color;
  const _NivelBar({
    required this.etiqueta,
    required this.rango,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              etiqueta,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            rango,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ChipPM extends StatelessWidget {
  final String etiqueta;
  final String descripcion;
  final Color color;
  const _ChipPM({
    required this.etiqueta,
    required this.descripcion,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              etiqueta,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              descripcion,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemMedicion extends StatelessWidget {
  final IconData icono;
  final String nombre;
  final String descripcion;
  final Color color;
  const _ItemMedicion({
    required this.icono,
    required this.nombre,
    required this.descripcion,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              descripcion,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            nombre,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Consejo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;
  const _Consejo({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 17),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PildoraEstado extends StatelessWidget {
  final String texto;
  final Color color;
  const _PildoraEstado({required this.texto, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjetas de contenido ─────────────────────────────────────────────────────

class _TarjetaCo2 extends StatelessWidget {
  const _TarjetaCo2();
  @override
  Widget build(BuildContext context) {
    return _Tarjeta(
      icono: Icons.cloud_outlined,
      titulo: '¿Qué es el CO₂?',
      colorAccento: const Color(0xFF00C9A7),
      cuerpo: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Parrafo(
            'El CO₂ es un gas invisible que producimos al respirar, al quemar gasolina y al usar electricidad.',
          ),
          SizedBox(height: 12),
          _NivelBar(
            etiqueta: 'Normal',
            rango: '< 400 ppm',
            color: Color(0xFF00C9A7),
          ),
          _NivelBar(
            etiqueta: 'Elevado',
            rango: '400–700 ppm',
            color: Color(0xFFFFC857),
          ),
          _NivelBar(
            etiqueta: 'Alto',
            rango: '> 700 ppm',
            color: Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }
}

class _TarjetaParticulas extends StatelessWidget {
  const _TarjetaParticulas();
  @override
  Widget build(BuildContext context) {
    return _Tarjeta(
      icono: Icons.blur_on_rounded,
      titulo: 'Partículas contaminantes',
      colorAccento: const Color(0xFFFFC857),
      cuerpo: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Parrafo(
            'Son partículas tan pequeñas que no las vemos, pero las respiramos.',
          ),
          SizedBox(height: 12),
          _ChipPM(
            etiqueta: 'PM2.5',
            descripcion: 'Muy finas · Penetran profundo en los pulmones',
            color: Color(0xFFFF6B6B),
          ),
          _ChipPM(
            etiqueta: 'PM10',
            descripcion: 'Más grandes · Polvo y tierra en suspensión',
            color: Color(0xFFFFC857),
          ),
          SizedBox(height: 4),
          _Parrafo(
            'Respirarlas de forma continua puede irritar la garganta y dificultar la respiración.',
          ),
        ],
      ),
    );
  }
}

class _TarjetaQueMide extends StatelessWidget {
  const _TarjetaQueMide();
  @override
  Widget build(BuildContext context) {
    return _Tarjeta(
      icono: Icons.sensors_rounded,
      titulo: '¿Qué mide esta aplicación?',
      colorAccento: const Color(0xFF7CC6FE),
      cuerpo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ItemMedicion(
            icono: Icons.co2_rounded,
            nombre: 'CO₂',
            descripcion: 'Dióxido de carbono en el aire',
            color: Color(0xFF00C9A7),
          ),
          const _ItemMedicion(
            icono: Icons.grain_rounded,
            nombre: 'PM2.5',
            descripcion: 'Partículas finas suspendidas',
            color: Color(0xFFFFC857),
          ),
          const _ItemMedicion(
            icono: Icons.thermostat_rounded,
            nombre: 'Temp.',
            descripcion: 'Temperatura ambiental',
            color: Color(0xFFFF9F7F),
          ),
          const SizedBox(height: 10),
          const Text(
            'Escala de calidad del aire',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _PildoraEstado(texto: 'Buena', color: Color(0xFF00C9A7)),
              SizedBox(width: 7),
              _PildoraEstado(texto: 'Moderada', color: Color(0xFFFFC857)),
              SizedBox(width: 7),
              _PildoraEstado(texto: 'Alta', color: Color(0xFFFF6B6B)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarjetaSalud extends StatelessWidget {
  const _TarjetaSalud();
  @override
  Widget build(BuildContext context) {
    return _Tarjeta(
      icono: Icons.favorite_border_rounded,
      titulo: 'Impacto en la salud',
      colorAccento: const Color(0xFFFF6B6B),
      cuerpo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Parrafo(
            'Respirar aire contaminado de forma continua puede afectar tu bienestar:',
          ),
          const SizedBox(height: 12),
          const _Fila(
            icono: Icons.air_rounded,
            color: Color(0xFFFF6B6B),
            texto: 'Problemas respiratorios y asma',
          ),
          const _Fila(
            icono: Icons.remove_red_eye_outlined,
            color: Color(0xFFFFC857),
            texto: 'Irritación en ojos, nariz y garganta',
          ),
          const _Fila(
            icono: Icons.battery_alert_rounded,
            color: Color(0xFFFFC857),
            texto: 'Fatiga y dolores de cabeza frecuentes',
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFF00C9A7).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: const Color(0xFF00C9A7).withValues(alpha: 0.20),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.child_care_rounded,
                  color: Color(0xFF00C9A7),
                  size: 15,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Los niños y adultos mayores son más vulnerables.',
                    style: TextStyle(
                      color: Color(0xFF00C9A7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaValledupar extends StatelessWidget {
  const _TarjetaValledupar();
  @override
  Widget build(BuildContext context) {
    return _Tarjeta(
      icono: Icons.location_city_rounded,
      titulo: 'Contexto en Valledupar',
      colorAccento: const Color(0xFF00C9A7),
      cuerpo: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Parrafo(
            'Valledupar tiene características que aumentan la contaminación del aire:',
          ),
          SizedBox(height: 12),
          _Fila(
            icono: Icons.wb_sunny_outlined,
            color: Color(0xFFFFC857),
            texto: 'Clima cálido todo el año',
          ),
          _Fila(
            icono: Icons.directions_car_outlined,
            color: Color(0xFFFFC857),
            texto: 'Tráfico vehicular intenso en zonas céntricas',
          ),
          _Fila(
            icono: Icons.local_fire_department_outlined,
            color: Color(0xFFFF6B6B),
            texto: 'Quemas agrícolas en temporadas secas',
          ),
          _Fila(
            icono: Icons.grain_rounded,
            color: Color(0xFFFFC857),
            texto: 'Polvo en suspensión por vías sin pavimentar',
          ),
        ],
      ),
    );
  }
}

class _TarjetaConsejos extends StatelessWidget {
  const _TarjetaConsejos();
  @override
  Widget build(BuildContext context) {
    return _Tarjeta(
      icono: Icons.tips_and_updates_outlined,
      titulo: 'Consejos según la calidad',
      colorAccento: const Color(0xFF7CC6FE),
      cuerpo: const Column(
        children: [
          _Consejo(
            icono: Icons.directions_run_rounded,
            titulo: 'Calidad moderada o alta',
            descripcion: 'Evita hacer ejercicio intenso al aire libre.',
            color: Color(0xFFFFC857),
          ),
          _Consejo(
            icono: Icons.masks_outlined,
            titulo: 'Niveles altos de PM2.5',
            descripcion: 'Usa mascarilla N95 si debes salir.',
            color: Color(0xFFFF6B6B),
          ),
          _Consejo(
            icono: Icons.notifications_active_outlined,
            titulo: 'Mantente informado',
            descripcion: 'Revisa la app antes de salir al exterior.',
            color: Color(0xFF00C9A7),
          ),
          _Consejo(
            icono: Icons.window_outlined,
            titulo: 'En casa',
            descripcion: 'Ventila tu hogar en horas de menor tráfico.',
            color: Color(0xFF7CC6FE),
          ),
        ],
      ),
    );
  }
}
