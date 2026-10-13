import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise_model.dart';
import '../models/workout_log_model.dart';
import '../models/workout_plan_model.dart';

class WorkoutService extends ChangeNotifier {
  bool get _hasFirebase => Firebase.apps.isNotEmpty;
  FirebaseFirestore? get _firestore => _hasFirebase ? FirebaseFirestore.instance : null;
  final Uuid _uuid = const Uuid();

  // Exercise Library
  List<ExerciseModel> _exercises = ExerciseModel.defaultExercises();
  List<ExerciseModel> get exercises => _exercises;

  // Active Workout Session
  bool _isWorkoutActive = false;
  String _activeWorkoutTitle = '';
  String? _activeProgramId;
  DateTime? _workoutStartTime;
  int _elapsedSeconds = 0;
  Timer? _workoutTimer;
  List<ExerciseLog> _activeExerciseLogs = [];

  // Completed Logs
  List<WorkoutLogModel> _recentWorkoutLogs = [];

  bool get isWorkoutActive => _isWorkoutActive;
  String get activeWorkoutTitle => _activeWorkoutTitle;
  int get elapsedSeconds => _elapsedSeconds;
  List<ExerciseLog> get activeExerciseLogs => _activeExerciseLogs;
  List<WorkoutLogModel> get recentWorkoutLogs => _recentWorkoutLogs;

  String get formattedDuration {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startWorkout({required String title, WorkoutDay? template}) {
    _isWorkoutActive = true;
    _activeWorkoutTitle = title;
    _workoutStartTime = DateTime.now();
    _elapsedSeconds = 0;
    _activeExerciseLogs = [];

    if (template != null) {
      for (final planEx in template.exercises) {
        _activeExerciseLogs.add(
          ExerciseLog(
            exerciseId: planEx.exerciseId,
            exerciseName: planEx.exerciseName,
            sets: List.generate(
              planEx.targetSets,
              (index) => ExerciseSetLog(
                setNumber: index + 1,
                weightKg: 20.0,
                reps: int.tryParse(planEx.targetReps) ?? 10,
                isCompleted: false,
              ),
            ),
          ),
        );
      }
    }

    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });

    notifyListeners();
  }

  void addExerciseToActiveWorkout(ExerciseModel exercise) {
    _activeExerciseLogs.add(
      ExerciseLog(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        sets: [
          ExerciseSetLog(
            setNumber: 1,
            weightKg: 20.0,
            reps: 10,
            isCompleted: false,
          ),
        ],
      ),
    );
    notifyListeners();
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExerciseLogs.length) return;
    final sets = _activeExerciseLogs[exerciseIndex].sets;
    final lastWeight = sets.isNotEmpty ? sets.last.weightKg : 20.0;
    final lastReps = sets.isNotEmpty ? sets.last.reps : 10;

    sets.add(
      ExerciseSetLog(
        setNumber: sets.length + 1,
        weightKg: lastWeight,
        reps: lastReps,
        isCompleted: false,
      ),
    );
    notifyListeners();
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExerciseLogs.length) return;
    final sets = _activeExerciseLogs[exerciseIndex].sets;
    if (setIndex < 0 || setIndex >= sets.length) return;

    sets.removeAt(setIndex);
    for (int i = 0; i < sets.length; i++) {
      sets[i].setNumber = i + 1;
    }
    notifyListeners();
  }

  void toggleSetCompleted(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExerciseLogs.length) return;
    final sets = _activeExerciseLogs[exerciseIndex].sets;
    if (setIndex < 0 || setIndex >= sets.length) return;

    sets[setIndex].isCompleted = !sets[setIndex].isCompleted;
    notifyListeners();
  }

  void updateSetWeight(int exerciseIndex, int setIndex, double weight) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExerciseLogs.length) return;
    final sets = _activeExerciseLogs[exerciseIndex].sets;
    if (setIndex < 0 || setIndex >= sets.length) return;

    sets[setIndex].weightKg = weight;
    notifyListeners();
  }

  void updateSetReps(int exerciseIndex, int setIndex, int reps) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExerciseLogs.length) return;
    final sets = _activeExerciseLogs[exerciseIndex].sets;
    if (setIndex < 0 || setIndex >= sets.length) return;

    sets[setIndex].reps = reps;
    notifyListeners();
  }

  Future<WorkoutLogModel?> finishWorkout(String userId) async {
    _workoutTimer?.cancel();

    final logId = _uuid.v4();
    final log = WorkoutLogModel(
      id: logId,
      userId: userId,
      programId: _activeProgramId,
      title: _activeWorkoutTitle.isEmpty ? 'Workout Session' : _activeWorkoutTitle,
      date: _workoutStartTime ?? DateTime.now(),
      durationSeconds: _elapsedSeconds,
      exercises: List.from(_activeExerciseLogs),
    );

    _recentWorkoutLogs.insert(0, log);

    if (_hasFirebase) {
      try {
        await _firestore?.collection('workout_logs').doc(logId).set(log.toMap());
      } catch (e) {
        debugPrint('Firestore save notice: $e');
      }
    }

    _isWorkoutActive = false;
    _activeExerciseLogs = [];
    _elapsedSeconds = 0;
    notifyListeners();
    return log;
  }

  void cancelWorkout() {
    _workoutTimer?.cancel();
    _isWorkoutActive = false;
    _activeExerciseLogs = [];
    _elapsedSeconds = 0;
    notifyListeners();
  }

  Future<void> fetchUserWorkoutLogs(String userId) async {
    if (!_hasFirebase) return;
    try {
      final snapshot = await _firestore!
          .collection('workout_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(20)
          .get();

      _recentWorkoutLogs = snapshot.docs
          .map((doc) => WorkoutLogModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching workout logs: $e');
    }
  }
}
