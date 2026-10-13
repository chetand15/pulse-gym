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
      // PUSH EXERCISES (Chest, Shoulders, Triceps)
      ExerciseModel(
        id: 'bench_press',
        name: 'Barbell Bench Press',
        muscleGroup: 'Chest',
        equipment: 'Barbell',
        instructions: 'Lie on the bench, grip barbell slightly wider than shoulders, lower to mid-chest, press up.',
      ),
      ExerciseModel(
        id: 'incline_db_press',
        name: 'Incline Dumbbell Press',
        muscleGroup: 'Chest',
        equipment: 'Dumbbell',
        instructions: 'Set bench to 30 degrees, press dumbbells upward, squeeze upper chest at the peak.',
      ),
      ExerciseModel(
        id: 'overhead_press',
        name: 'Overhead Barbell Press',
        muscleGroup: 'Shoulders',
        equipment: 'Barbell',
        instructions: 'Grip bar at shoulder width, lock core and glutes, press bar overhead until arms extend.',
      ),
      ExerciseModel(
        id: 'lateral_raise',
        name: 'Dumbbell Lateral Raise',
        muscleGroup: 'Shoulders',
        equipment: 'Dumbbell',
        instructions: 'Raise dumbbells to sides up to shoulder height with slight elbow bend, control descent.',
      ),
      ExerciseModel(
        id: 'tricep_pushdown',
        name: 'Cable Tricep Pushdown',
        muscleGroup: 'Arms (Triceps)',
        equipment: 'Cable',
        instructions: 'Keep elbows pinned to ribs, push rope down until triceps are fully contracted.',
      ),
      ExerciseModel(
        id: 'skull_crusher',
        name: 'EZ-Bar Skull Crusher',
        muscleGroup: 'Arms (Triceps)',
        equipment: 'Barbell',
        instructions: 'Lie on bench, lower bar to forehead bending at elbows, extend arms back to start.',
      ),

      // PULL EXERCISES (Back, Rear Delts, Biceps)
      ExerciseModel(
        id: 'deadlift',
        name: 'Conventional Deadlift',
        muscleGroup: 'Back & Posterior',
        equipment: 'Barbell',
        instructions: 'Hinge at hips, keep spine neutral, drive heels into ground and stand up straight.',
      ),
      ExerciseModel(
        id: 'barbell_row',
        name: 'Bent-Over Barbell Row',
        muscleGroup: 'Back',
        equipment: 'Barbell',
        instructions: 'Hinge forward at 45 degrees, pull barbell to lower rib cage, squeeze shoulder blades.',
      ),
      ExerciseModel(
        id: 'lat_pulldown',
        name: 'Wide-Grip Lat Pulldown',
        muscleGroup: 'Back (Lats)',
        equipment: 'Cable / Machine',
        instructions: 'Grip bar wide, pull down towards upper chest while leaning back slightly, squeeze lats.',
      ),
      ExerciseModel(
        id: 'face_pull',
        name: 'Cable Face Pull',
        muscleGroup: 'Rear Delts & Upper Back',
        equipment: 'Cable',
        instructions: 'Set pulley to eye level with rope, pull towards face while rotating hands back.',
      ),
      ExerciseModel(
        id: 'dumbbell_curl',
        name: 'Bicep Dumbbell Curl',
        muscleGroup: 'Arms (Biceps)',
        equipment: 'Dumbbell',
        instructions: 'Elbows tight at sides, curl weights up, squeeze peak contraction, lower slowly.',
      ),
      ExerciseModel(
        id: 'hammer_curl',
        name: 'Neutral Hammer Curl',
        muscleGroup: 'Arms (Brachialis/Biceps)',
        equipment: 'Dumbbell',
        instructions: 'Palms facing each other, curl dumbbells upward, build forearm and arm thickness.',
      ),

      // LEG EXERCISES (Quads, Hamstrings, Glutes, Calves)
      ExerciseModel(
        id: 'squat',
        name: 'Barbell Back Squat',
        muscleGroup: 'Legs (Quads/Glutes)',
        equipment: 'Barbell',
        instructions: 'Rest bar on traps, feet shoulder-width, squat to parallel, drive up through heels.',
      ),
      ExerciseModel(
        id: 'rdl',
        name: 'Romanian Deadlift (RDL)',
        muscleGroup: 'Legs (Hamstrings/Glutes)',
        equipment: 'Barbell / Dumbbell',
        instructions: 'Keep slight bend in knees, push hips backward until deep hamstring stretch, thrust forward.',
      ),
      ExerciseModel(
        id: 'leg_press',
        name: '45-Degree Leg Press',
        muscleGroup: 'Legs (Quads)',
        equipment: 'Machine',
        instructions: 'Lower platform until knees are at 90 degrees, press through mid-foot without knee hyperextension.',
      ),
      ExerciseModel(
        id: 'leg_extension',
        name: 'Leg Extension',
        muscleGroup: 'Legs (Quads)',
        equipment: 'Machine',
        instructions: 'Sit tight, extend shins upward, hold quad contraction at the top for 1 second.',
      ),
      ExerciseModel(
        id: 'hamstring_curl',
        name: 'Lying Hamstring Curl',
        muscleGroup: 'Legs (Hamstrings)',
        equipment: 'Machine',
        instructions: 'Curl roller pad up to glutes, keep hips flat on bench, lower slowly under control.',
      ),
      ExerciseModel(
        id: 'calf_raise',
        name: 'Standing Calf Raise',
        muscleGroup: 'Calves',
        equipment: 'Machine',
        instructions: 'Drive onto toes with full ankle extension, lower down for deep calf stretch.',
      ),
    ];
  }
}
