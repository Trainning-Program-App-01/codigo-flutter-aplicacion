import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prueba_proyecto/api/train_api.dart';
import 'package:prueba_proyecto/theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.api});

  final TrainApi api;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _userName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _dioMessage(Object e) {
    if (e is DioException) {
      return e.response?.data?.toString() ?? e.message ?? e.toString();
    }
    return e.toString();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final data = await widget.api.register(
        userName: _userName.text,
        password: _password.text,
        email: _email.text,
      );
      final id = data['id'];
      if (id is num) {
        await widget.api.saveUserId(id.toInt());
        await widget.api.saveUserDisplayName(_userName.text);
      }
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
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
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    color: AppColors.cardInner,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.neon, width: 1),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    color: AppColors.neon,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Usuario',
                    style: TextStyle(
                      color: AppColors.neon,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _customTextField(
                  controller: _userName,
                  hint: 'tu nombre de usuario',
                  isPassword: false,
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: TextStyle(
                      color: AppColors.neon,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _customTextField(
                  controller: _email,
                  hint: 'correo@ejemplo.com',
                  isPassword: false,
                ),
                const SizedBox(height: 20),
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
                  onPressed: _busy ? null : _submit,
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.neon,
                          ),
                        )
                      : const Text(
                          'crear cuenta',
                          style: TextStyle(color: AppColors.neon, fontSize: 18),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _busy ? null : () => Navigator.pop(context),
                  child: const Text(
                    'volver al login',
                    style: TextStyle(color: AppColors.neon, fontWeight: FontWeight.w600),
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
        hintStyle: TextStyle(color: AppColors.neon.withOpacity(0.6)),
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
