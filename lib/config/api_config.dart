import 'dart:io' show Platform;

/// Base URL of the Spring Boot API including context path [trainapp].
///
/// Override at run time, for example:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8081/trainapp`
class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv.endsWith('/') ? fromEnv.substring(0, fromEnv.length - 1) : fromEnv;
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081/trainapp';
    }
    return 'http://127.0.0.1:8081/trainapp';
  }
}
