import 'package:flutter/foundation.dart';
import 'package:prueba_proyecto/api/train_api.dart';
import 'package:prueba_proyecto/models/workout_models.dart';

/// Lista de entrenamientos cargada desde la API.
class WorkoutStore extends ChangeNotifier {
  WorkoutStore(this._api);

  final TrainApi _api;

  final List<Workout> _workouts = [];
  bool loading = false;
  String? lastError;

  List<Workout> get workouts => List.unmodifiable(_workouts);

  Future<void> refreshFromApi() async {
    loading = true;
    lastError = null;
    notifyListeners();
    try {
      final data = await _api.getMyWorkouts(page: 0, size: 50);
      final raw = data['content'] as List<dynamic>? ?? [];
      _workouts
        ..clear()
        ..addAll(
          raw.map((e) => Workout.fromJson(e as Map<String, dynamic>)),
        );
    } catch (e) {
      lastError = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _workoutBody({
    required String workoutName,
    required DateTime workoutDate,
    String? workoutDescription,
    required List<WorkoutBlock> blocks,
  }) {
    final body = <String, dynamic>{
      'workoutName': workoutName,
      'workoutDate':
          '${workoutDate.year.toString().padLeft(4, '0')}-${workoutDate.month.toString().padLeft(2, '0')}-${workoutDate.day.toString().padLeft(2, '0')}',
      'blocks': blocks
          .map(
            (b) => {
              'blockName': b.name,
              'blockDescription': b.description,
            },
          )
          .toList(),
    };
    if (workoutDescription != null && workoutDescription.trim().isNotEmpty) {
      body['workoutDescription'] = workoutDescription.trim();
    }
    return body;
  }

  Future<void> createWorkoutRemote({
    required String workoutName,
    required DateTime workoutDate,
    String? workoutDescription,
    required List<WorkoutBlock> blocks,
  }) async {
    await _api.createWorkout(_workoutBody(
      workoutName: workoutName,
      workoutDate: workoutDate,
      workoutDescription: workoutDescription,
      blocks: blocks,
    ));
    await refreshFromApi();
  }

  Future<void> updateWorkoutRemote({
    required int workoutId,
    required String workoutName,
    required DateTime workoutDate,
    String? workoutDescription,
    required List<WorkoutBlock> blocks,
  }) async {
    await _api.updateWorkout(
      workoutId,
      _workoutBody(
        workoutName: workoutName,
        workoutDate: workoutDate,
        workoutDescription: workoutDescription,
        blocks: blocks,
      ),
    );
    await refreshFromApi();
  }

  Future<void> deleteWorkoutRemote(int workoutId) async {
    await _api.deleteWorkout(workoutId);
    await refreshFromApi();
  }

  void addWorkout(Workout workout) {
    _workouts.insert(0, workout);
    notifyListeners();
  }
}
