import 'package:dio/dio.dart';
import 'package:prueba_proyecto/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainApi {
  TrainApi() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${ApiConfig.baseUrl}/',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;
          final isAuth = path == 'auth/login' ||
              path == 'auth/register' ||
              path.endsWith('/auth/login') ||
              path.endsWith('/auth/register');
          if (!isAuth && _userId != null) {
            options.headers['X-User-Id'] = _userId.toString();
          }
          return handler.next(options);
        },
      ),
    );
  }

  late final Dio _dio;
  int? _userId;

  int? get userId => _userId;

  Future<void> restoreSession() async {
    final p = await SharedPreferences.getInstance();
    _userId = p.getInt(_kUserId);
    await p.remove(_kLegacyToken);
  }

  Future<void> saveUserId(int id) async {
    _userId = id;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kUserId, id);
  }

  Future<void> saveUserDisplayName(String? value) async {
    final p = await SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      await p.remove(_kDisplayName);
    } else {
      await p.setString(_kDisplayName, value);
    }
  }

  Future<String?> loadUserDisplayName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kDisplayName);
  }

  Future<void> clearSession() async {
    _userId = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_kUserId);
    await p.remove(_kDisplayName);
    await p.remove(_kLegacyToken);
  }

  Future<Map<String, dynamic>> login({
    required String identity,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'auth/login',
      data: {'identity': identity, 'password': password},
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> register({
    required String userName,
    required String password,
    required String email,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'auth/register',
      data: {
        'userName': userName,
        'password': password,
        'email': email,
      },
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> getMyWorkouts({int page = 0, int size = 50}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'workouts/mine',
      queryParameters: {'page': page, 'size': size},
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> createWorkout(Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>('workouts', data: body);
    return res.data!;
  }

  Future<Map<String, dynamic>> updateWorkout(int id, Map<String, dynamic> body) async {
    final res = await _dio.put<Map<String, dynamic>>('workouts/$id', data: body);
    return res.data!;
  }

  Future<void> deleteWorkout(int id) async {
    await _dio.delete<void>('workouts/$id');
  }

  static const _kUserId = 'trainapp_user_id';
  static const _kDisplayName = 'trainapp_display_name';
  static const _kLegacyToken = 'trainapp_jwt';
}
