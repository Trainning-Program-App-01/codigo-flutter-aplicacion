import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prueba_proyecto/api/train_api.dart';
import 'package:prueba_proyecto/state/workout_store.dart';
import 'package:prueba_proyecto/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.api, required this.store});

  final TrainApi api;
  final WorkoutStore store;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identity = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _identity.dispose();
    _password.dispose();
    super.dispose();
  }

  String _dioMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return e.response?.data?.toString() ?? e.message ?? e.toString();
    }
    return e.toString();
  }

  Future<void> _login() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final data = await widget.api.login(
        identity: _identity.text.trim(),
        password: _password.text,
      );
      final id = data['id'];
      if (id is! num) {
        throw StateError('Respuesta sin id de usuario');
      }
      await widget.api.saveUserId(id.toInt());
      final display = '${data['name'] ?? ''} ${data['surname'] ?? ''}'.trim();
      await widget.api.saveUserDisplayName(display.isEmpty ? data['userName']?.toString() : display);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_dioMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: AppColors.cardInner,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.neon, width: 1),
                  ),
                ),
                const SizedBox(height: 50),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Usuario o email',
                    style: TextStyle(
                      color: AppColors.neon,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _customTextField(
                  controller: _identity,
                  hint: 'usuario o correo',
                  isPassword: false,
                ),
                const SizedBox(height: 25),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Contraseña',
                    style: TextStyle(
                      color: AppColors.neon,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _customTextField(
                  controller: _password,
                  hint: '••••••••',
                  isPassword: true,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _busy ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardInner,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: const StadiumBorder(
                      side: BorderSide(color: AppColors.neon, width: 2),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neon),
                        )
                      : const Text(
                          'login',
                          style: TextStyle(color: AppColors.neon, fontSize: 18),
                        ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _busy ? null : () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    'Crear cuenta',
                    style: TextStyle(color: AppColors.neon, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.card.withOpacity(0.5),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    'reset your password',
                    style: TextStyle(color: AppColors.neon),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String hint,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.neon.withOpacity(0.6),
        ),
        filled: true,
        fillColor: AppColors.cardInner,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.neon, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.neon, width: 3),
        ),
      ),
    );
  }
}
