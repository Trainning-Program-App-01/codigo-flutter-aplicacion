import 'dart:io' show Platform;

/// Base URL de la API Spring Boot (incluye el context-path `/trainapp`).
///
/// 1. **Para APK / móvil real**:
///    cambia [kHostIp] a la IP del equipo donde corre la API (mira la IP del Mac
///    con `ipconfig getifaddr en0` para WiFi). El móvil debe estar en la misma
///    red WiFi que el ordenador y el puerto 8081 abierto.
///
/// 2. **Para emulador Android** (sin tocar IP):
///    Android Studio puede acceder al host con `10.0.2.2`; basta con borrar
///    [kHostIp] (dejarlo vacío) y se usará esa dirección automáticamente.
///
/// 3. **Override puntual sin recompilar `ApiConfig`**:
///    `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8081/trainapp`
class ApiConfig {
  ApiConfig._();

  /// IP del equipo donde corre la API (Docker o local). Cambia esto antes de
  /// generar el APK para conectar el móvil por WiFi.
  static const String kHostIp = '172.20.10.9';

  /// Puerto donde escucha la API.
  static const int kPort = 8081;

  /// Context path configurado en Spring Boot.
  static const String kContextPath = '/trainapp';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv.endsWith('/')
          ? fromEnv.substring(0, fromEnv.length - 1)
          : fromEnv;
    }
    if (kHostIp.isNotEmpty) {
      return 'http://$kHostIp:$kPort$kContextPath';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$kPort$kContextPath';
    }
    return 'http://127.0.0.1:$kPort$kContextPath';
  }
}
