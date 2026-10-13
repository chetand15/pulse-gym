import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/workout_plan_model.dart';
import '../../core/services/trainer_service.dart';

class ProgramBuilderScreen extends StatefulWidget {
  const ProgramBuilderScreen({super.key});

  @override
  State<ProgramBuilderScreen> createState() => _ProgramBuilderScreenState();
}

class _ProgramBuilderScreenState extends State<ProgramBuilderScreen> {
  final Uuid _uuid = const Uuid();

  void _showCreateProgramDialog(BuildContext context, TrainerService trainer) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('New Program Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Program Name (e.g. 5-Day Push/Pull)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Description / Goal'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.black),
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final newProg = WorkoutProgramModel(
                  id: _uuid.v4(),
                  title: title,
                  description: descController.text.trim(),
                  createdBy: 'trainer_demo_1',
                  assignedTo: [],
                  createdAt: DateTime.now(),
                  days: [
                    WorkoutDay(
                      dayName: 'Day 1: Upper Body Strength',
                      exercises: [
                        WorkoutPlanExercise(exerciseId: 'bench_press', exerciseName: 'Barbell Bench Press', targetSets: 4, targetReps: '6-8'),
                        WorkoutPlanExercise(exerciseId: 'barbell_row', exerciseName: 'Bent-Over Barbell Row', targetSets: 4, targetReps: '8-10'),
                      ],
                    ),
                  ],
                );
                trainer.addProgramTemplate(newProg);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 Program template created!')),
                );
              }
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trainer = context.watch<TrainerService>();
    final templates = trainer.templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Program Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.secondary),
            tooltip: 'New Program Template',
            onPressed: () => _showCreateProgramDialog(context, trainer),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.add),
            label: const Text('BUILD NEW WORKOUT TEMPLATE', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _showCreateProgramDialog(context, trainer),
          ),
          const SizedBox(height: 24),

          const Text(
            'Saved Program Templates',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...templates.map((prog) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            prog.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${prog.days.length} Days Split',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      prog.description,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const Divider(color: AppColors.divider, height: 20),

                    // Days preview
                    ...prog.days.map((day) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(day.dayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(
                                    day.exercises.map((e) => '${e.exerciseName} (${e.targetSets}x${e.targetReps})').join(' • '),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.secondary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.person_add, size: 16, color: AppColors.secondary),
                          label: const Text('Assign to Client', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Assigned "${prog.title}" to Jordan Smith!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
