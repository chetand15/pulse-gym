class WorkoutPlanExercise {
  final String exerciseId;
  final String exerciseName;
  final int targetSets;
  final String targetReps; // e.g., "8-12" or "5"
  final int restSeconds;

  WorkoutPlanExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.targetSets,
    required this.targetReps,
    this.restSeconds = 90,
  });

  factory WorkoutPlanExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutPlanExercise(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      targetSets: map['targetSets'] ?? 3,
      targetReps: map['targetReps'] ?? '10',
      restSeconds: map['restSeconds'] ?? 90,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'restSeconds': restSeconds,
    };
  }
}

class WorkoutDay {
  final String dayName; // e.g. "Chest & Triceps"
  final List<WorkoutPlanExercise> exercises;

  WorkoutDay({
    required this.dayName,
    required this.exercises,
  });

  factory WorkoutDay.fromMap(Map<String, dynamic> map) {
    return WorkoutDay(
      dayName: map['dayName'] ?? 'Workout Day',
      exercises: (map['exercises'] as List<dynamic>? ?? [])
          .map((e) => WorkoutPlanExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayName': dayName,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }
}

class WorkoutProgramModel {
  final String id;
  final String title;
  final String description;
  final String createdBy; // trainerId
  final List<String> assignedTo; // clientIds
  final List<WorkoutDay> days;
  final DateTime createdAt;

  WorkoutProgramModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    this.assignedTo = const [],
    required this.days,
    required this.createdAt,
  });

  factory WorkoutProgramModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutProgramModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      assignedTo: List<String>.from(map['assignedTo'] ?? []),
      days: (map['days'] as List<dynamic>? ?? [])
          .map((d) => WorkoutDay.fromMap(d as Map<String, dynamic>))
          .toList(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'days': days.map((d) => d.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
