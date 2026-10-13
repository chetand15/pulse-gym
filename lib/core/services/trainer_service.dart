import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/workout_plan_model.dart';
import '../models/check_in_model.dart';
import '../models/nutrition_model.dart';

class TrainerClientInfo {
  final UserModel user;
  final double complianceRate; // e.g., 0.90 for 90%
  final String currentProgramTitle;
  final String lastActiveText;
  final double currentWeightKg;

  TrainerClientInfo({
    required this.user,
    required this.complianceRate,
    required this.currentProgramTitle,
    required this.lastActiveText,
    required this.currentWeightKg,
  });
}

class TrainerService extends ChangeNotifier {
  bool get _hasFirebase => Firebase.apps.isNotEmpty;
  FirebaseFirestore? get _firestore => _hasFirebase ? FirebaseFirestore.instance : null;
  final Uuid _uuid = const Uuid();

  List<TrainerClientInfo> _clients = [
    TrainerClientInfo(
      user: UserModel(
        uid: 'client_demo_1',
        email: 'jordan@gympro.com',
        displayName: 'Jordan Smith',
        role: UserRole.client,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      complianceRate: 0.92,
      currentProgramTitle: 'Hypertrophy 4-Day Split',
      lastActiveText: '2 hours ago',
      currentWeightKg: 78.5,
    ),
    TrainerClientInfo(
      user: UserModel(
        uid: 'client_demo_2',
        email: 'sarah@gympro.com',
        displayName: 'Sarah Jenkins',
        role: UserRole.client,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      complianceRate: 0.85,
      currentProgramTitle: 'Strength & Conditioning',
      lastActiveText: 'Yesterday',
      currentWeightKg: 62.0,
    ),
    TrainerClientInfo(
      user: UserModel(
        uid: 'client_demo_3',
        email: 'marcus@gympro.com',
        displayName: 'Marcus Lee',
        role: UserRole.client,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      complianceRate: 0.70,
      currentProgramTitle: 'Fat Loss & Lean Muscle',
      lastActiveText: '3 days ago',
      currentWeightKg: 88.2,
    ),
  ];

  List<WorkoutProgramModel> _templates = [
    WorkoutProgramModel(
      id: 'template_ppl',
      title: 'Push Pull Legs (PPL) Split',
      description: 'Gold standard hypertrophy split dividing training by functional muscle mechanics: Push, Pull, and Legs.',
      createdBy: 'trainer_demo_1',
      assignedTo: ['client_demo_1'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      days: [
        WorkoutDay(
          dayName: 'Push Day (Chest, Shoulders, Triceps)',
          exercises: [
            WorkoutPlanExercise(exerciseId: 'bench_press', exerciseName: 'Barbell Bench Press', targetSets: 4, targetReps: '8-10', restSeconds: 120),
            WorkoutPlanExercise(exerciseId: 'incline_db_press', exerciseName: 'Incline Dumbbell Press', targetSets: 3, targetReps: '10-12', restSeconds: 90),
            WorkoutPlanExercise(exerciseId: 'overhead_press', exerciseName: 'Overhead Barbell Press', targetSets: 3, targetReps: '8-10', restSeconds: 90),
            WorkoutPlanExercise(exerciseId: 'lateral_raise', exerciseName: 'Dumbbell Lateral Raise', targetSets: 4, targetReps: '12-15', restSeconds: 60),
            WorkoutPlanExercise(exerciseId: 'tricep_pushdown', exerciseName: 'Cable Tricep Pushdown', targetSets: 3, targetReps: '12-15', restSeconds: 60),
          ],
        ),
        WorkoutDay(
          dayName: 'Pull Day (Back, Rear Delts, Biceps)',
          exercises: [
            WorkoutPlanExercise(exerciseId: 'deadlift', exerciseName: 'Conventional Deadlift', targetSets: 3, targetReps: '5', restSeconds: 150),
            WorkoutPlanExercise(exerciseId: 'lat_pulldown', exerciseName: 'Wide-Grip Lat Pulldown', targetSets: 4, targetReps: '8-10', restSeconds: 90),
            WorkoutPlanExercise(exerciseId: 'barbell_row', exerciseName: 'Bent-Over Barbell Row', targetSets: 3, targetReps: '8-10', restSeconds: 90),
            WorkoutPlanExercise(exerciseId: 'face_pull', exerciseName: 'Cable Face Pull', targetSets: 3, targetReps: '15', restSeconds: 60),
            WorkoutPlanExercise(exerciseId: 'dumbbell_curl', exerciseName: 'Bicep Dumbbell Curl', targetSets: 3, targetReps: '10-12', restSeconds: 60),
            WorkoutPlanExercise(exerciseId: 'hammer_curl', exerciseName: 'Neutral Hammer Curl', targetSets: 3, targetReps: '12', restSeconds: 60),
          ],
        ),
        WorkoutDay(
          dayName: 'Leg Day (Quads, Hamstrings, Calves)',
          exercises: [
            WorkoutPlanExercise(exerciseId: 'squat', exerciseName: 'Barbell Back Squat', targetSets: 4, targetReps: '6-8', restSeconds: 120),
            WorkoutPlanExercise(exerciseId: 'rdl', exerciseName: 'Romanian Deadlift (RDL)', targetSets: 3, targetReps: '8-10', restSeconds: 90),
            WorkoutPlanExercise(exerciseId: 'leg_press', exerciseName: '45-Degree Leg Press', targetSets: 3, targetReps: '10-12', restSeconds: 90),
            WorkoutPlanExercise(exerciseId: 'hamstring_curl', exerciseName: 'Lying Hamstring Curl', targetSets: 3, targetReps: '12-15', restSeconds: 60),
            WorkoutPlanExercise(exerciseId: 'calf_raise', exerciseName: 'Standing Calf Raise', targetSets: 4, targetReps: '15', restSeconds: 45),
          ],
        ),
      ],
    ),
  ];

  List<CheckInModel> _pendingCheckIns = [
    CheckInModel(
      id: 'checkin_1',
      clientId: 'client_demo_1',
      trainerId: 'trainer_demo_1',
      date: DateTime.now().subtract(const Duration(hours: 12)),
      weightKg: 78.5,
      bodyFatPercentage: 14.5,
      clientNotes: 'Felt very energized this week! Hit bench PR (90kg for 6 reps). Nutrition was on point.',
      isReviewed: false,
    ),
    CheckInModel(
      id: 'checkin_2',
      clientId: 'client_demo_2',
      trainerId: 'trainer_demo_1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      weightKg: 62.0,
      clientNotes: 'Slight knee stiffness during squats, otherwise great workouts.',
      isReviewed: false,
    ),
  ];

  List<TrainerClientInfo> get clients => _clients;
  List<WorkoutProgramModel> get templates => _templates;
  List<CheckInModel> get pendingCheckIns => _pendingCheckIns;

  void addProgramTemplate(WorkoutProgramModel program) {
    _templates.add(program);
    notifyListeners();
  }

  void submitTrainerFeedback(String checkInId, String feedback) {
    final index = _pendingCheckIns.indexWhere((c) => c.id == checkInId);
    if (index != -1) {
      final old = _pendingCheckIns[index];
      _pendingCheckIns[index] = CheckInModel(
        id: old.id,
        clientId: old.clientId,
        trainerId: old.trainerId,
        date: old.date,
        weightKg: old.weightKg,
        bodyFatPercentage: old.bodyFatPercentage,
        photoUrls: old.photoUrls,
        clientNotes: old.clientNotes,
        trainerFeedback: feedback,
        isReviewed: true,
      );
      notifyListeners();
    }
  }
}
