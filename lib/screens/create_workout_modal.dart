import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prueba_proyecto/models/workout_models.dart';
import 'package:prueba_proyecto/state/workout_store.dart';
import 'package:prueba_proyecto/theme/app_theme.dart';

class _BlockDraft {
  _BlockDraft({String? name, String? description})
      : name = TextEditingController(text: name),
        description = TextEditingController(text: description);

  final TextEditingController name;
  final TextEditingController description;

  void dispose() {
    name.dispose();
    description.dispose();
  }
}

class CreateWorkoutModal extends StatefulWidget {
  const CreateWorkoutModal({
    super.key,
    required this.store,
    this.editWorkout,
  });

  final WorkoutStore store;
  final Workout? editWorkout;

  bool get isEditing => editWorkout != null;

  @override
  State<CreateWorkoutModal> createState() => _CreateWorkoutModalState();
}

class _CreateWorkoutModalState extends State<CreateWorkoutModal> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final List<_BlockDraft> _blocks = [];
  DateTime? _workoutDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final w = widget.editWorkout;
    if (w != null) {
      _title.text = w.title;
      _description.text = w.description ?? '';
      _workoutDate = w.workoutDate;
      if (w.blocks.isEmpty) {
        _blocks.add(_BlockDraft());
      } else {
        for (final b in w.blocks) {
          _blocks.add(_BlockDraft(name: b.name, description: b.description));
        }
      }
    } else {
      _blocks.add(_BlockDraft());
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _workoutDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _workoutDate = picked);
  }

  String _dioMessage(Object e) {
    if (e is DioException) {
      return e.response?.data?.toString() ?? e.message ?? e.toString();
    }
    return e.toString();
  }

  List<WorkoutBlock> _collectBlocks() {
    final built = <WorkoutBlock>[];
    for (final b in _blocks) {
      if (b.name.text.trim().isEmpty || b.description.text.trim().isEmpty) {
        return [];
      }
      built.add(
        WorkoutBlock(
          name: b.name.text.trim(),
          description: b.description.text.trim(),
        ),
      );
    }
    return built;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_title.text.trim().isEmpty) {
      _toast('Indica un nombre para el entrenamiento.');
      return;
    }
    if (_workoutDate == null) {
      _toast('Selecciona la fecha del entrenamiento.');
      return;
    }
    final built = _collectBlocks();
    if (built.isEmpty) {
      _toast('Todos los bloques deben tener nombre y descripción.');
      return;
    }
    setState(() => _saving = true);
    try {
      final desc = _description.text.trim().isEmpty ? null : _description.text.trim();
      if (widget.isEditing) {
        await widget.store.updateWorkoutRemote(
          workoutId: int.parse(widget.editWorkout!.id),
          workoutName: _title.text.trim(),
          workoutDate: _workoutDate!,
          workoutDescription: desc,
          blocks: built,
        );
      } else {
        await widget.store.createWorkoutRemote(
          workoutName: _title.text.trim(),
          workoutDate: _workoutDate!,
          workoutDescription: desc,
          blocks: built,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _toast(_dioMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.cardInner),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.isEditing;
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
                  if (editing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Editar entrenamiento',
                        style: TextStyle(
                          color: AppColors.neon.withOpacity(0.95),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _labeledField(
                    label: 'Nombre del entrenamiento',
                    child: _customTextField(
                      controller: _title,
                      hint: 'Ej. Pierna / HIIT mañana',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _labeledField(
                    label: 'Descripción (opcional)',
                    child: _customTextField(
                      controller: _description,
                      hint: 'Notas…',
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _pickDate,
                    icon: const Icon(Icons.event, color: AppColors.neon),
                    label: Text(
                      _workoutDate == null
                          ? 'Fecha del entrenamiento'
                          : '${_workoutDate!.day}/${_workoutDate!.month}/${_workoutDate!.year}',
                      style: const TextStyle(color: AppColors.neon),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.neon),
                      minimumSize: const Size.fromHeight(48),
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
                                onPressed: _saving ? null : () => _confirmBlock(i),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  _outlineButton(
                    label: 'add block',
                    onPressed: _saving ? null : _addBlock,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.neon,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Text(
                              editing ? 'guardar cambios' : 'crear workout',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              onTap: _saving ? null : () => Navigator.of(context).pop(),
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

  Widget _outlineButton({required String label, required VoidCallback? onPressed}) {
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
