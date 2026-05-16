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
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _email = TextEditingController();
  DateTime? _birthDate;
  bool _busy = false;

  @override
  void dispose() {
    _userName.dispose();
    _password.dispose();
    _name.dispose();
    _surname.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
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

  Future<void> _submit() async {
    if (_busy) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de nacimiento.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final iso =
          '${_birthDate!.year.toString().padLeft(4, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}';
      final data = await widget.api.register(
        userName: _userName.text.trim(),
        password: _password.text,
        name: _name.text.trim(),
        surname: _surname.text.trim(),
        email: _email.text.trim(),
        fNacIso: iso,
      );
      final id = data['id'];
      if (id is! num) {
        throw StateError('Respuesta sin id de usuario');
      }
      await widget.api.saveUserId(id.toInt());
      final display = '${data['name'] ?? ''} ${data['surname'] ?? ''}'.trim();
      await widget.api.saveUserDisplayName(display.isEmpty ? data['userName']?.toString() : display);
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.neon,
        title: const Text('Registro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field('Usuario', _userName),
            _field('Contraseña', _password, obscure: true),
            _field('Nombre', _name),
            _field('Apellidos', _surname),
            _field('Email', _email),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _pickBirth,
              icon: const Icon(Icons.calendar_today, color: AppColors.neon),
              label: Text(
                _birthDate == null
                    ? 'Fecha de nacimiento'
                    : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                style: const TextStyle(color: AppColors.neon),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.neon),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.neon,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.neon),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.neon),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.neon, width: 2),
          ),
        ),
      ),
    );
  }
}
