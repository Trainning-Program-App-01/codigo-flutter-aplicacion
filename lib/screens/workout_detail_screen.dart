import 'package:flutter/material.dart';
import 'package:prueba_proyecto/models/workout_models.dart';
import 'package:prueba_proyecto/screens/create_workout_modal.dart';
import 'package:prueba_proyecto/state/workout_store.dart';
import 'package:prueba_proyecto/theme/app_theme.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workout,
    required this.store,
  });

  final Workout workout;
  final WorkoutStore store;

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late Workout _workout;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
  }

  Future<void> _openEdit() async {
    final updated = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.82),
      builder: (context) => CreateWorkoutModal(
        store: widget.store,
        editWorkout: _workout,
      ),
    );
    if (!mounted) return;
    if (updated == true) {
      final match = widget.store.workouts.where((w) => w.id == _workout.id).toList();
      if (match.isNotEmpty) {
        setState(() => _workout = match.first);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrenamiento actualizado.'),
          backgroundColor: AppColors.card,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Eliminar entrenamiento', style: TextStyle(color: AppColors.neon)),
        content: Text(
          '¿Seguro que quieres eliminar "${_workout.title}"? Se borrará de la base de datos.',
          style: TextStyle(color: AppColors.neon.withOpacity(0.9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.neon)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.store.deleteWorkoutRemote(int.parse(_workout.id));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card,
                  side: const BorderSide(color: AppColors.neon, width: 2),
                ),
                icon: const Icon(Icons.close, color: AppColors.neon),
              ),
            ),
            if (_busy)
              const Center(child: CircularProgressIndicator(color: AppColors.neon)),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.neon, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neon.withOpacity(0.25),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _workout.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.neon,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _workout.dateLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.neon.withOpacity(0.85),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _workout.description?.trim().isNotEmpty == true
                              ? _workout.description!.trim()
                              : 'Sin descripción',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.neon.withOpacity(0.75),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _busy ? null : _openEdit,
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                label: const Text('Editar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.neon,
                                  side: const BorderSide(color: AppColors.neon, width: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _busy ? null : _confirmDelete,
                                icon: const Icon(Icons.delete_outline, size: 20),
                                label: const Text('Eliminar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent, width: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.neon,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(_workout.blocks.length, (i) {
                          final block = _workout.blocks[i];
                          final n = (i + 1).toString().padLeft(2, '0');
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: i == _workout.blocks.length - 1 ? 0 : 22,
                            ),
                            child: _BlockSection(
                              blockIndex: n,
                              block: block,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockSection extends StatelessWidget {
  const _BlockSection({
    required this.blockIndex,
    required this.block,
  });

  final String blockIndex;
  final WorkoutBlock block;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bloque $blockIndex',
          style: const TextStyle(
            color: AppColors.neon,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.neon,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: AppColors.neon.withOpacity(0.6),
        ),
        const SizedBox(height: 14),
        Text(
          block.name,
          style: const TextStyle(
            color: AppColors.neon,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          block.description,
          style: TextStyle(
            color: AppColors.neon.withOpacity(0.92),
            fontSize: 15,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
