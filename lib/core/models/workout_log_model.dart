class ExerciseSetLog {
  int setNumber;
  double weightKg;
  int reps;
  double? rpe; // 1 to 10
  bool isCompleted;

  ExerciseSetLog({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.rpe,
    this.isCompleted = false,
  });

  factory ExerciseSetLog.fromMap(Map<String, dynamic> map) {
    return ExerciseSetLog(
      setNumber: map['setNumber'] ?? 1,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      reps: map['reps'] ?? 0,
      rpe: (map['rpe'] as num?)?.toDouble(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'weightKg': weightKg,
      'reps': reps,
      'rpe': rpe,
      'isCompleted': isCompleted,
    };
  }
}

class ExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final List<ExerciseSetLog> sets;

  ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  factory ExerciseLog.fromMap(Map<String, dynamic> map) {
    return ExerciseLog(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      sets: (map['sets'] as List<dynamic>? ?? [])
          .map((s) => ExerciseSetLog.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }

  double get volumeKg {
    return sets.where((s) => s.isCompleted).fold(0.0, (sum, s) => sum + (s.weightKg * s.reps));
  }
}

class WorkoutLogModel {
  final String id;
  final String userId;
  final String? programId;
  final String title;
  final DateTime date;
  final int durationSeconds;
  final List<ExerciseLog> exercises;

  WorkoutLogModel({
    required this.id,
    required this.userId,
    this.programId,
    required this.title,
    required this.date,
    required this.durationSeconds,
    required this.exercises,
  });

  double get totalVolumeKg {
    return exercises.fold(0.0, (sum, e) => sum + e.volumeKg);
  }

  int get totalCompletedSets {
    return exercises.fold(0, (sum, e) => sum + e.sets.where((s) => s.isCompleted).length);
  }

  factory WorkoutLogModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutLogModel(
      id: id,
      userId: map['userId'] ?? '',
      programId: map['programId'],
      title: map['title'] ?? 'Workout',
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : DateTime.now(),
      durationSeconds: map['durationSeconds'] ?? 0,
      exercises: (map['exercises'] as List<dynamic>? ?? [])
          .map((e) => ExerciseLog.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'programId': programId,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'durationSeconds': durationSeconds,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'totalVolumeKg': totalVolumeKg,
    };
  }
}
