import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/workout_plan_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/workout_service.dart';
import '../../core/services/nutrition_service.dart';
import '../../core/services/trainer_service.dart';

class ClientDashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const ClientDashboardScreen({super.key, required this.onNavigateTab});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _selectedDayIndex = 0; // 0 = Push, 1 = Pull, 2 = Legs

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final workout = context.watch<WorkoutService>();
    final nutrition = context.watch<NutritionService>();
    final trainer = context.watch<TrainerService>();

    final user = auth.currentUser;
    final todayLog = nutrition.todayLog;
    final plan = nutrition.activePlan;

    // Retrieve PPL Split Template
    final pplTemplate = trainer.templates.isNotEmpty ? trainer.templates.first : null;
    final availableDays = pplTemplate?.days ?? [];
    final selectedWorkoutDay = availableDays.isNotEmpty && _selectedDayIndex < availableDays.length
        ? availableDays[_selectedDayIndex]
        : null;

    final calPercent = (todayLog.totalCalories / plan.targetCalories).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.displayName ?? "Athlete"} 👋',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Client Member Portal • PPL Routine',
              style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textMuted),
            tooltip: 'Sign Out / Switch Role',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stat Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Workouts Logged',
                    value: '${workout.recentWorkoutLogs.length + 3}',
                    subtitle: 'This Month',
                    icon: Icons.fitness_center,
                    accentColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Water Intake',
                    value: '${(todayLog.waterMl / 1000).toStringAsFixed(1)}L',
                    subtitle: 'Target: 3.0L',
                    icon: Icons.water_drop,
                    accentColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // PUSH / PULL / LEGS Day Selector Section
            const Text(
              'Choose Today’s Split',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _buildSplitChip(index: 0, title: '🏋️ Push Day', subtitle: 'Chest & Arms'),
                const SizedBox(width: 8),
                _buildSplitChip(index: 1, title: '🧗 Pull Day', subtitle: 'Back & Biceps'),
                const SizedBox(width: 8),
                _buildSplitChip(index: 2, title: '🦵 Leg Day', subtitle: 'Quads & Glutes'),
              ],
            ),
            const SizedBox(height: 16),

            // Today's Active PPL Workout Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.card,
                    AppColors.card.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedDayIndex == 0
                              ? 'PUSH FOCUS (CHEST / DELTS / TRICEPS)'
                              : (_selectedDayIndex == 1
                                  ? 'PULL FOCUS (LATS / UPPER BACK / BICEPS)'
                                  : 'LEG FOCUS (QUADS / POSTERIOR CHAIN)'),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Icon(Icons.bolt, color: AppColors.primary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedWorkoutDay?.dayName ?? 'Push Day',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${selectedWorkoutDay?.exercises.length ?? 5} Targeted Movements • Estimated ~55 mins',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Exercises preview pill list
                  if (selectedWorkoutDay != null) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: selectedWorkoutDay.exercises.map((ex) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            '${ex.exerciseName} (${ex.targetSets} sets)',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Start workout action
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: Icon(workout.isWorkoutActive ? Icons.timer : Icons.play_arrow),
                    label: Text(
                      workout.isWorkoutActive
                          ? 'RESUME CURRENT WORKOUT (${workout.formattedDuration})'
                          : 'START ${_selectedDayIndex == 0 ? "PUSH" : (_selectedDayIndex == 1 ? "PULL" : "LEG")} WORKOUT',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: () {
                      if (!workout.isWorkoutActive && selectedWorkoutDay != null) {
                        workout.startWorkout(
                          title: selectedWorkoutDay.dayName,
                          template: selectedWorkoutDay,
                        );
                      }
                      widget.onNavigateTab(1); // Switch to live Workout tab
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nutrition Summary Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Nutrition",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => widget.onNavigateTab(2), // Switch to Nutrition tab
                  child: const Text('View All Meals', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Calories Consumed', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              text: '${todayLog.totalCalories}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.calories),
                              children: [
                                TextSpan(
                                  text: ' / ${plan.targetCalories} kcal',
                                  style: const TextStyle(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      CircularProgressIndicator(
                        value: calPercent,
                        strokeWidth: 6,
                        backgroundColor: AppColors.surfaceLight,
                        color: AppColors.calories,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 12),

                  _buildMacroBar(label: 'Protein', current: todayLog.totalProtein, target: plan.targetProteinGrams, color: AppColors.protein),
                  const SizedBox(height: 8),
                  _buildMacroBar(label: 'Carbohydrates', current: todayLog.totalCarbs, target: plan.targetCarbsGrams, color: AppColors.carbs),
                  const SizedBox(height: 8),
                  _buildMacroBar(label: 'Healthy Fats', current: todayLog.totalFat, target: plan.targetFatGrams, color: AppColors.fats),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitChip({required int index, required String title, required String subtitle}) {
    final isSelected = _selectedDayIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDayIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.18) : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildMacroBar({
    required String label,
    required double current,
    required double target,
    required Color color,
  }) {
    final percent = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(
              '${current.toStringAsFixed(0)}g / ${target.toStringAsFixed(0)}g',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: AppColors.surfaceLight,
            color: color,
          ),
        ),
      ],
    );
  }
}
