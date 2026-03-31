import 'package:flutter/material.dart';

import '../../../widgets/layout/contenedor_base.dart';
import '../widgets/mapa_widget.dart';
import '../widgets/tarjeta_indicador.dart';

class InicioVista extends StatelessWidget {
  const InicioVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: ContenedorBase(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calidad del Aire',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'En tiempo real',
                                style: TextStyle(
                                  color: Color(0xFF00C9A7),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const MapaWidget(),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: const Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _LeyendaEstado(
                            color: Color(0xFF00C9A7),
                            texto: 'Buena',
                          ),
                          _LeyendaEstado(
                            color: Color(0xFFFFC857),
                            texto: 'Moderada',
                          ),
                          _LeyendaEstado(
                            color: Color(0xFFFF6B6B),
                            texto: 'Alta',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Indicadores principales',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, cardConstraints) {
                        final cardWidth =
                            (cardConstraints.maxWidth - 12) / 2;
                        final useTwoColumns = cardConstraints.maxWidth >= 360;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: useTwoColumns
                                  ? cardWidth
                                  : cardConstraints.maxWidth,
                              child: const TarjetaIndicador(
                                icono: Icons.co2_rounded,
                                etiqueta: 'CO₂ (ppm)',
                                valor: '412',
                                descripcion: 'Nivel estable en zona centro.',
                                color: Color(0xFF00C9A7),
                              ),
                            ),
                            SizedBox(
                              width: useTwoColumns
                                  ? cardWidth
                                  : cardConstraints.maxWidth,
                              child: const TarjetaIndicador(
                                icono: Icons.blur_on_rounded,
                                etiqueta: 'Partículas',
                                valor: '36 µg/m³',
                                descripcion: 'Presencia moderada de PM2.5.',
                                color: Color(0xFFFFC857),
                              ),
                            ),
                            SizedBox(
                              width: cardConstraints.maxWidth,
                              child: const TarjetaIndicador(
                                icono: Icons.thermostat_rounded,
                                etiqueta: 'Temperatura',
                                valor: '29 °C',
                                descripcion: 'Sensación cálida durante la tarde.',
                                color: Color(0xFF7CC6FE),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const _BarraInferiorDashboard(),
    );
  }
}

class _LeyendaEstado extends StatelessWidget {
  final Color color;
  final String texto;

  const _LeyendaEstado({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BarraInferiorDashboard extends StatelessWidget {
  const _BarraInferiorDashboard();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF112A34),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          children: [
            _ItemNav(
              icono: Icons.home_rounded,
              texto: 'Inicio',
              activo: true,
            ),
            _ItemNav(
              icono: Icons.air_rounded,
              texto: 'Calidad actual',
            ),
            _ItemNav(
              icono: Icons.person_outline_rounded,
              texto: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemNav extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool activo;

  const _ItemNav({
    required this.icono,
    required this.texto,
    this.activo = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? const Color(0xFF00C9A7) : Colors.white60;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: activo ? const Color(0x1400C9A7) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
