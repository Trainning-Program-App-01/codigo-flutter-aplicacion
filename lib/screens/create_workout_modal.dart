import 'package:flutter/material.dart';
import 'package:prueba_proyecto/models/workout_models.dart';
import 'package:prueba_proyecto/state/workout_store.dart';
import 'package:prueba_proyecto/theme/app_theme.dart';

class _BlockDraft {
  _BlockDraft()
      : name = TextEditingController(),
        description = TextEditingController();

  final TextEditingController name;
  final TextEditingController description;

  void dispose() {
    name.dispose();
    description.dispose();
  }
}

class CreateWorkoutModal extends StatefulWidget {
  const CreateWorkoutModal({super.key, required this.store});

  final WorkoutStore store;

  @override
  State<CreateWorkoutModal> createState() => _CreateWorkoutModalState();
}

class _CreateWorkoutModalState extends State<CreateWorkoutModal> {
  final TextEditingController _date = TextEditingController();
  final List<_BlockDraft> _blocks = [];

  @override
  void initState() {
    super.initState();
    _blocks.add(_BlockDraft());
  }

  @override
  void dispose() {
    _date.dispose();
    for (final b in _blocks) {
      b.dispose();
    }
    super.dispose();
  }

  void _addBlock() {
    setState(() => _blocks.add(_BlockDraft()));
  }

  void _confirmBlock(int index) {
    final b = _blocks[index];
    if (b.name.text.trim().isEmpty || b.description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rellena el nombre y la descripción del bloque.'),
          backgroundColor: AppColors.cardInner,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bloque ${index + 1} guardado en el borrador.'),
        backgroundColor: AppColors.card,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _createWorkout() {
    if (_date.text.trim().isEmpty) {
      _toast('Indica la fecha del entrenamiento.');
      return;
    }
    final built = <WorkoutBlock>[];
    for (final b in _blocks) {
      if (b.name.text.trim().isEmpty || b.description.text.trim().isEmpty) {
        _toast('Todos los bloques deben tener nombre y descripción.');
        return;
      }
      built.add(
        WorkoutBlock(
          name: b.name.text.trim(),
          description: b.description.text.trim(),
        ),
      );
    }
    final workout = Workout(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      dateLabel: _date.text.trim(),
      blocks: built,
    );
    widget.store.addWorkout(workout);
    Navigator.of(context).pop(true);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.cardInner),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 560),
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.neon.withOpacity(0.55), width: 2),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  _labeledField(
                    label: 'Fecha',
                    child: _customTextField(
                      controller: _date,
                      hint: 'Ej. Lunes 13 de octubre',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(_blocks.length, (i) {
                    final draft = _blocks[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardInner,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.neon.withOpacity(0.45),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Bloque ${i + 1}',
                              style: TextStyle(
                                color: AppColors.neon.withOpacity(0.9),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _customTextField(
                              controller: draft.name,
                              hint: 'block name',
                              small: true,
                            ),
                            const SizedBox(height: 12),
                            _customTextField(
                              controller: draft.description,
                              hint: 'block description...',
                              small: true,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _outlineButton(
                                label: 'confirm',
                                onPressed: () => _confirmBlock(i),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  _outlineButton(
                    label: 'add block',
                    onPressed: _addBlock,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _createWorkout,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.neon,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'crear workout',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -15,
            left: -15,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neon, width: 2),
                ),
                child: const Center(
                  child: Text(
                    'X',
                    style: TextStyle(
                      color: AppColors.neon,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.neon.withOpacity(0.95),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _outlineButton({required String label, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neon,
        side: const BorderSide(color: AppColors.neon, width: 2),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String hint,
    bool small = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: Colors.white,
        fontSize: small ? 14 : 16,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.neon.withOpacity(0.45),
          fontSize: small ? 14 : 16,
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: AppColors.neon.withOpacity(0.45),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.neon, width: 2),
        ),
      ),
    );
  }
}
