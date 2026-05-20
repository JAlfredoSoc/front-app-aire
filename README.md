# AirMonitor - Frontend App Calidad del Aire

Aplicación móvil Flutter para monitoreo de calidad del aire en Valledupar, Cesar. Integra visualización de sensores IoT, mapas interactivos, predicciones con IA y contenido educativo sobre contaminación ambiental.

## Características Principales

- **Autenticación**: Login/registro con JWT vía API REST
- **Mapa Interactivo**: Visualización de sensores en tiempo real con `flutter_map`
- **Mapa de Calor**: Interpolación de datos de contaminación (CO₂, PM2.5, temperatura)
- **Predicciones IA**: Modelo CNN para predecir niveles de CO₂ futuros
- **Estadísticas**: Tendencias, promedios por zona y distribución de calidad
- **Educación**: Contenido informativo sobre impacto en salud y contaminantes
- **Alertas**: Notificaciones de zonas con calidad del aire moderada/alta
- **Perfil**: Gestión de usuario y reentrenamiento del modelo de IA

## Arquitectura

### Estructura de Carpetas

```dart
lib/
├── auth/                    # Módulo de autenticación
│   ├── vistas/             # LoginVista, RegistroVista
│   └── widgets/            # FormularioLogin, FormularioRegistro
├── core/                    # Infraestructura central
│   ├── rutas/              # AppRutas (definición de rutas)
│   ├── shell/              # AppShell (layout principal con header/navbar)
│   └── tema/               # Colores, TemaApp
├── modelos/                # Modelos de dominio
│   └── sensor.dart         # Sensor, EstadoAire, AlertaMedicion
├── modulos/                # Features de negocio
│   ├── educacion/          # Contenido educativo
│   ├── estadisticas/       # Dashboard de estadísticas
│   └── mapa/               # Mapa interactivo + mapa de calor
├── servicios/              # Capa de servicios (API)
│   ├── auth_servicio.dart
│   ├── sensor_servicio.dart
│   ├── prediccion_servicio.dart
│   └── mapa_calor_servicio.dart
├── widgets/                # Componentes reutilizables
│   ├── botones/            # BotonPrincipal
│   ├── inputs/             # InputTexto
│   ├── comunes/            # TarjetaMedicion, ChipEstado, IndicadorDato
│   └── layout/             # ContenedorBase
└── main.dart               # Punto de entrada
```

### Patrones de Diseño

- **Feature-based modular**: Cada módulo (auth, mapa, estadisticas) es autocontenido
- **Shell pattern**: `AppShell` provee header/navbar persistentes, el contenido cambia con `IndexedStack`
- **Service layer**: Servicios estáticos encapsulan llamadas HTTP al backend
- **Reusable widgets**: Componentes atómicos reutilizados en múltiples pantallas

## Modelo de Datos

### Sensor

Representa una medición de calidad del aire en un punto geográfico.

```dart
class Sensor {
  final String id;
  final String zona;              // Nombre de la zona (ej: "Centro")
  final LatLng posicion;         // Coordenadas (lat, lng)
  final double co2;              // ppm
  final double temperatura;      // °C
  final double pm25;             // µg/m³
  final EstadoAire estado;      // buena | moderada | alta
}
```

**Estados de calidad del aire**:
- `buena`: CO₂ < 550 ppm, PM2.5 < 25 µg/m³
- `moderada`: CO₂ 550-800 ppm, PM2.5 25-50 µg/m³
- `alta`: CO₂ > 800 ppm, PM2.5 > 50 µg/m³

## Integración con Backend

### Base URL

- **Web/Emulador**: `http://localhost:8000`
- **Android Emulator**: `http://10.0.2.2:8000` (alias de localhost)

### Endpoints API

#### Autenticación

```dart
POST /api/auth/login
Body: { email, password }
Response: { access_token, usuario: { email, nombre } }

POST /api/auth/registro
Body: { nombre, email, password }
Response: 200 + login automático
```

#### Sensores

```dart
GET /api/sensores
Response: [
  {
    id, zona, lat, lng,
    co2, temperatura, pm25,
    estado: "buena"|"moderada"|"alta"
  }
]
```

#### Mapa de Calor

```dart
GET /api/mapa-calor/?tipo=co2
Headers: Authorization: Bearer {token}
Response: {
  puntos: [
    { lat, lng, valor, peso }
  ]
}
```

#### Predicciones IA

```dart
POST /api/predicciones/{idSensor}
Headers: Authorization: Bearer {token}
Body: { id_sensor, horas_futura: 3 }
Response: {
  valor_predicho: 650.5,
  nivel_riesgo: "Bajo"|"Alto"
}

POST /api/predicciones/entrenar
Headers: Authorization: Bearer {token}
Response: { mensaje: "Modelo entrenado con éxito" }

GET /api/predicciones/estadisticas/globales
Headers: Authorization: Bearer {token}
Response: {
  efectividad_ia: 92.5,
  total_predicciones: 150
}
```

## Servicios

### AuthServicio

Gestiona autenticación y sesión de usuario.

- `login(email, password)`: Autentica y guarda token JWT en SharedPreferences
- `registro(nombre, email, password)`: Crea usuario y hace login automático
- `logout()`: Elimina token y datos de sesión
- `estaLogueado()`: Verifica si existe token almacenado

### SensorServicio

Obtiene y procesa datos de sensores.

- `obtenerTodos()`: Fetch todos los sensores desde API
- `promedio`: Calcula promedio de todas las mediciones (getter estático)
- `alertas`: Lista de sensores con estado != buena (getter estático)

### PrediccionServicio

Integra con modelo de IA para predicciones.

- `predecir(idSensor, horas)`: Predice CO₂ futuro para un sensor
- `entrenarModelo()`: Dispara reentrenamiento del modelo CNN con datos reales
- `obtenerEstadisticasGlobales()`: Métricas de efectividad de la IA

### MapaCalorServicio

Obtiene puntos interpolados para visualización de mapa de calor.

- `obtenerPuntos(tipo)`: Retorna puntos con lat, lng, valor, peso para tipo dado (co2, pm25, temperatura)

## Flujo de Usuario

### 1. Login/Registro

1. Usuario ingresa credenciales en `FormularioLogin` o `FormularioRegistro`
2. `AuthServicio.login/registro` llama API backend
3. Si exitoso, guarda JWT y datos en `SharedPreferences`
4. Navega a `AppShell` (tab inicial: Inicio)

### 2. Navegación Principal

`AppShell` mantiene 3 tabs persistentes con `IndexedStack`:

- **Inicio (0)**: `EducacionContenido` - tarjetas informativas
- **Mapa (1)**: `MapaContenido` - mapa interactivo + panel inferior
- **Estadísticas (2)**: `EstadisticasContenido` - dashboard de métricas

### 3. Mapa Interactivo

1. `MapaContenido` carga sensores via `SensorServicio.obtenerTodos()`
2. Renderiza marcadores con `MarcadorSensor` (color según estado)
3. Usuario toca marcador → `_seleccionar(sensor)` actualiza estado
4. Panel inferior muestra `TarjetaMedicion` del sensor seleccionado
5. Botón "Calcular" en sección IA llama `PrediccionServicio.predecir()`
6. Switch superior activa/desactiva mapa de calor via `MapaCalorServicio`

### 4. Mapa de Calor

1. Al activar switch, `MapaCalorServicio.obtenerPuntos('co2')` fetch puntos interpolados
2. Cada punto tiene `valor` (CO₂) y `peso` (influencia visual)
3. `_obtenerColorCalor(valor)` mapea valor a gradiente: Azul → Violeta → Rojo
4. Renderiza círculos semitransparentes con `CircleLayer` (flutter_map)

### 5. Estadísticas

1. `EstadisticasContenido` carga sensores y stats IA al `initState`
2. Calcula promedios, máximos, mínimos, distribución por estado
3. Renderiza:
   - Tarjeta resumen general
   - Rendimiento IA (efectividad, total predicciones)
   - Gráfico de tendencia del día (barras)
   - Máximo/mínimo registrado
   - Lista de zonas con barras de progreso
   - Distribución de calidad (barra apilada)
   - Consejos según calidad

### 6. Perfil y Entrenamiento IA

1. Modal perfil (header → icono persona) muestra nombre/email desde SharedPreferences
2. Botón "Actualizar IA con datos reales" llama `PrediccionServicio.entrenarModelo()`
3. Backend reentrena modelo CNN con datos históricos de Firebase
4. Muestra SnackBar con resultado (éxito/error)
5. Botón "Cerrar sesión" elimina token y navega a login

## Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^8.2.1          # Mapa interactivo OpenStreetMap
  latlong2: ^0.9.1              # Coordenadas geográficas
  http: ^1.6.0                  # Cliente HTTP
  shared_preferences: ^2.5.5   # Persistencia local
  cupertino_icons: ^1.0.8       # Iconos iOS
```

## Configuración de Entorno

### Requisitos

- Flutter SDK >= 3.11.1
- Backend FastAPI corriendo en puerto 8000
- Android Emulator o dispositivo físico

### Ejecución

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en emulador
flutter run

# Ejecutar en web
flutter run -d chrome
```

## Decisiones Técnicas

### IndexedStack en AppShell

**Por qué**: Mantener estado de cada tab sin recargar widgets al navegar.

**Alternativa descartada**: `Navigator` con rutas separadas causaría recarga completa y pérdida de scroll/estado.

### Servicios Estáticos

**Por qué**: Simplicidad - no requiere inyección de dependencias ni providers. Estado global (caché de sensores) accesible desde cualquier widget.

**Trade-off**: Dificultad para testing y mock en unit tests. Para apps más complejas, considerar Riverpod/Provider.

### Mapa de Calor con CircleLayer

**Por qué**: `flutter_map` no tiene capa de calor nativa. `CircleLayer` con círculos semitransparentes superpuestos simula efecto de interpolación visual.

**Limitación**: No es interpolación matemática real (IDW/Kriging). Backend debe pre-calcular puntos interpolados.

### Colores Hardcodeados en Sensor

**Por qué**: Consistencia visual entre mapa, estadísticas y tarjetas. Centralizado en `colorEstado` getter.

**Mejora futura**: Mover a `AppColores` con constantes por estado.

## Estado del Proyecto

**Versión**: 1.0.0+1

**Últimos commits**:
- `b6e1d39`: Implementación de vista informativa, mapa más ampliado, estadísticas, notificaciones y perfil
- `9efae6c`: Solución temporal del mapa y arreglos
- `d5bb1da`: Implementación del inicio y del mapa
- `65b0d21`: Creación del formulario de registro
- `8ed2172`: Corrección del espacio en blanco del login
- `aff345d`: Primera vista del login
- `d6799ba`: Creación del front app móvil calidad del aire urbano

## Próximos Pasos

- [ ] Agregar tests unitarios para servicios
- [ ] Implementar refresh token JWT
- [ ] Agregar modo offline con caché local
- [ ] Internacionalización (i18n)
- [ ] Gráficos más avanzados (fl_chart)
- [ ] Notificaciones push para alertas críticas
