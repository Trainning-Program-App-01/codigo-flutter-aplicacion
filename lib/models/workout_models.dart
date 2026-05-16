import 'package:flutter/foundation.dart';

/// Un bloque dentro de un entrenamiento (nombre + descripción del bloque).
@immutable
class WorkoutBlock {
  const WorkoutBlock({
    required this.name,
    required this.description,
  });

  final String name;
  final String description;

  factory WorkoutBlock.fromJson(Map<String, dynamic> json) {
    return WorkoutBlock(
      name: json['blockName'] as String? ?? '',
      description: json['blockDescription'] as String? ?? '',
    );
  }
}

/// Entrenamiento completo (respuesta del backend + datos de UI).
@immutable
class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.dateLabel,
    this.workoutDateIso,
    this.description,
    required this.blocks,
  });

  final String id;
  final String title;
  final String dateLabel;
  /// Fecha formato `yyyy-MM-dd`.
  final String? workoutDateIso;
  final String? description;
  final List<WorkoutBlock> blocks;

  DateTime? get workoutDate {
    final iso = workoutDateIso;
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    final iso = json['workoutDate'] as String?;
    final blocksJson = json['blocks'] as List<dynamic>? ?? [];
    final name = (json['workoutName'] as String?)?.trim() ?? '';
    return Workout(
      id: (json['id'] as num).toString(),
      title: name.isEmpty ? 'Entrenamiento' : name,
      dateLabel: iso == null ? '' : _formatIsoDate(iso),
      workoutDateIso: iso,
      description: json['workoutDescription'] as String?,
      blocks: blocksJson
          .map((e) => WorkoutBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

String _formatIsoDate(String iso) {
  try {
    final d = DateTime.parse(iso);
    const week = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    final w = week[(d.weekday - 1) % 7];
    return '$w ${d.day}/${d.month}/${d.year}';
  } catch (_) {
    return iso;
  }
}
