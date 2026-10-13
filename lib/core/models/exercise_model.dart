class ExerciseModel {
  final String id;
  final String name;
  final String muscleGroup; // Chest, Back, Legs, Shoulders, Arms, Core
  final String equipment;   // Barbell, Dumbbell, Machine, Cable, Bodyweight
  final String instructions;
  final String? videoUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.instructions,
    this.videoUrl,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExerciseModel(
      id: id,
      name: map['name'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
      equipment: map['equipment'] ?? '',
      instructions: map['instructions'] ?? '',
      videoUrl: map['videoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'instructions': instructions,
      'videoUrl': videoUrl,
    };
  }

  static List<ExerciseModel> defaultExercises() {
    return [
      ExerciseModel(
        id: 'bench_press',
        name: 'Barbell Bench Press',
        muscleGroup: 'Chest',
        equipment: 'Barbell',
        instructions: 'Lie on the bench, grip the barbell slightly wider than shoulder-width, lower to mid-chest, and press up explosively.',
      ),
      ExerciseModel(
        id: 'squat',
        name: 'Barbell Back Squat',
        muscleGroup: 'Legs',
        equipment: 'Barbell',
        instructions: 'Rest bar on upper back, feet shoulder-width apart, hinge hips back and squat down until thighs are parallel to floor, drive up.',
      ),
      ExerciseModel(
        id: 'deadlift',
        name: 'Conventional Deadlift',
        muscleGroup: 'Back',
        equipment: 'Barbell',
        instructions: 'Stand mid-foot under barbell, hinge down and grip bar, keep chest up, spine neutral, drive through heels to stand upright.',
      ),
      ExerciseModel(
        id: 'overhead_press',
        name: 'Overhead Barbell Press',
        muscleGroup: 'Shoulders',
        equipment: 'Barbell',
        instructions: 'Grip bar at shoulder width, lock core and glutes, press bar overhead until arms are fully extended.',
      ),
      ExerciseModel(
        id: 'barbell_row',
        name: 'Bent-Over Barbell Row',
        muscleGroup: 'Back',
        equipment: 'Barbell',
        instructions: 'Hinge forward at 45 degrees, pull barbell towards lower rib cage, squeeze shoulder blades, lower with control.',
      ),
      ExerciseModel(
        id: 'dumbbell_curl',
        name: 'Bicep Dumbbell Curl',
        muscleGroup: 'Arms',
        equipment: 'Dumbbell',
        instructions: 'Keep elbows tucked to your side, curl dumbbells upward, squeeze biceps at the top, lower slowly.',
      ),
      ExerciseModel(
        id: 'tricep_pushdown',
        name: 'Cable Tricep Pushdown',
        muscleGroup: 'Arms',
        equipment: 'Cable',
        instructions: 'Use rope or straight bar attachment, keep elbows pinned at ribs, push down until triceps are fully contracted.',
      ),
    ];
  }
}
