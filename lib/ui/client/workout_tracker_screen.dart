import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/exercise_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/workout_service.dart';

class WorkoutTrackerScreen extends StatelessWidget {
  const WorkoutTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutService>();
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          workout.isWorkoutActive ? workout.activeWorkoutTitle : 'Workout Tracker',
        ),
        actions: [
          if (workout.isWorkoutActive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    workout.formattedDuration,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _confirmFinishWorkout(context, auth, workout),
              child: const Text(
                'FINISH',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
      body: workout.isWorkoutActive
          ? _buildActiveWorkoutView(context, workout)
          : _buildWorkoutHomeView(context, workout),
    );
  }

  Widget _buildWorkoutHomeView(BuildContext context, WorkoutService workout) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Quick start button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          icon: const Icon(Icons.add, size: 24),
          label: const Text('START EMPTY WORKOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          onPressed: () {
            workout.startWorkout(title: 'Quick Workout');
          },
        ),
        const SizedBox(height: 28),

        const Text(
          'Recent Completed Workouts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (workout.recentWorkoutLogs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Column(
              children: [
                Icon(Icons.history, color: AppColors.textMuted, size: 48),
                SizedBox(height: 12),
                Text(
                  'No workouts logged yet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Start your first session to track weights, sets and personal records.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...workout.recentWorkoutLogs.map((log) {
            final mins = log.durationSeconds ~/ 60;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${log.date.day}/${log.date.month}/${log.date.year}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(Icons.timer, '${mins}m'),
                        const SizedBox(width: 12),
                        _buildStatChip(Icons.line_weight, '${log.totalVolumeKg.toStringAsFixed(0)} kg volume'),
                        const SizedBox(width: 12),
                        _buildStatChip(Icons.check_circle_outline, '${log.totalCompletedSets} sets'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      log.exercises.map((e) => e.exerciseName).join(', '),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildActiveWorkoutView(BuildContext context, WorkoutService workout) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ...workout.activeExerciseLogs.asMap().entries.map((entry) {
          final exerciseIndex = entry.key;
          final exerciseLog = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseLog.exerciseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Table Header
                  const Row(
                    children: [
                      SizedBox(width: 36, child: Text('SET', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                      Expanded(child: Center(child: Text('KG', style: TextStyle(color: AppColors.textMuted, fontSize: 12)))),
                      Expanded(child: Center(child: Text('REPS', style: TextStyle(color: AppColors.textMuted, fontSize: 12)))),
                      SizedBox(width: 48, child: Center(child: Text('DONE', style: TextStyle(color: AppColors.textMuted, fontSize: 12)))),
                    ],
                  ),
                  const Divider(color: AppColors.divider),

                  // Sets list
                  ...exerciseLog.sets.asMap().entries.map((setEntry) {
                    final setIndex = setEntry.key;
                    final setLog = setEntry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${setLog.setNumber}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Weight input
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextFormField(
                                initialValue: setLog.weightKg.toStringAsFixed(1),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) {
                                  final num = double.tryParse(val) ?? setLog.weightKg;
                                  workout.updateSetWeight(exerciseIndex, setIndex, num);
                                },
                              ),
                            ),
                          ),
                          // Reps input
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextFormField(
                                initialValue: '${setLog.reps}',
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) {
                                  final num = int.tryParse(val) ?? setLog.reps;
                                  workout.updateSetReps(exerciseIndex, setIndex, num);
                                },
                              ),
                            ),
                          ),
                          // Checkmark toggle
                          SizedBox(
                            width: 48,
                            child: IconButton(
                              icon: Icon(
                                setLog.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                                color: setLog.isCompleted ? AppColors.success : AppColors.textMuted,
                              ),
                              onPressed: () {
                                workout.toggleSetCompleted(exerciseIndex, setIndex);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),

                  // Add set button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 38),
                    ),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.textSecondary),
                    label: const Text('+ Add Set', style: TextStyle(color: AppColors.textSecondary)),
                    onPressed: () => workout.addSet(exerciseIndex),
                  ),
                ],
              ),
            ),
          );
        }),

        // Add Exercise button
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add, color: AppColors.primary),
          label: const Text('Add Exercise', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          onPressed: () => _showAddExerciseSheet(context, workout),
        ),
        const SizedBox(height: 16),

        // Cancel workout
        Center(
          child: TextButton(
            onPressed: () => _confirmCancelWorkout(context, workout),
            child: const Text('Discard Workout', style: TextStyle(color: AppColors.error)),
          ),
        ),
      ],
    );
  }

  void _showAddExerciseSheet(BuildContext context, WorkoutService workout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Select Exercise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...workout.exercises.map((ex) {
              return ListTile(
                title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${ex.muscleGroup} • ${ex.equipment}'),
                trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onTap: () {
                  workout.addExerciseToActiveWorkout(ex);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _confirmFinishWorkout(BuildContext context, AuthService auth, WorkoutService workout) {
    final userId = auth.currentUser?.uid ?? 'client_demo_1';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Finish Workout?'),
        content: Text(
          'Total time: ${workout.formattedDuration}\nTotal sets completed: ${workout.activeExerciseLogs.fold(0, (sum, e) => sum + e.sets.where((s) => s.isCompleted).length)}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              await workout.finishWorkout(userId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 Great workout! Session saved.')),
                );
              }
            },
            child: const Text('SAVE & FINISH'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelWorkout(BuildContext context, WorkoutService workout) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Discard Workout?'),
        content: const Text('All active sets and timer progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Training')),
          TextButton(
            onPressed: () {
              workout.cancelWorkout();
              Navigator.pop(ctx);
            },
            child: const Text('Discard', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
