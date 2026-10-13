import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/workout_service.dart';
import '../../core/services/nutrition_service.dart';
import '../../core/services/trainer_service.dart';

class ClientDashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const ClientDashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final workout = context.watch<WorkoutService>();
    final nutrition = context.watch<NutritionService>();
    final trainer = context.watch<TrainerService>();

    final user = auth.currentUser;
    final todayLog = nutrition.todayLog;
    final plan = nutrition.activePlan;
    final template = trainer.templates.isNotEmpty ? trainer.templates.first : null;
    final todayWorkoutDay = template != null && template.days.isNotEmpty ? template.days.first : null;

    final calPercent = (todayLog.totalCalories / plan.targetCalories).clamp(0.0, 1.0);
    final proteinPercent = (todayLog.totalProtein / plan.targetProteinGrams).clamp(0.0, 1.0);

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
              'Client Member Portal',
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

            // Today's Assigned Workout Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.card,
                    AppColors.card.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
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
                        child: const Text(
                          'ASSIGNED BY COACH ALEX',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppColors.textMuted, size: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    todayWorkoutDay?.dayName ?? 'Upper Body Hypertrophy',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${todayWorkoutDay?.exercises.length ?? 4} Exercises • ~50 mins • Moderate Intensity',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Start workout action
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    icon: Icon(workout.isWorkoutActive ? Icons.timer : Icons.play_arrow),
                    label: Text(
                      workout.isWorkoutActive
                          ? 'RESUME WORKOUT (${workout.formattedDuration})'
                          : 'START WORKOUT',
                    ),
                    onPressed: () {
                      if (!workout.isWorkoutActive && todayWorkoutDay != null) {
                        workout.startWorkout(
                          title: todayWorkoutDay.dayName,
                          template: todayWorkoutDay,
                        );
                      }
                      onNavigateTab(1); // Switch to Workout tab
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
                  onPressed: () => onNavigateTab(2), // Switch to Nutrition tab
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

                  // Macronutrient bars
                  _buildMacroBar(
                    label: 'Protein',
                    current: todayLog.totalProtein,
                    target: plan.targetProteinGrams,
                    color: AppColors.protein,
                  ),
                  const SizedBox(height: 8),
                  _buildMacroBar(
                    label: 'Carbohydrates',
                    current: todayLog.totalCarbs,
                    target: plan.targetCarbsGrams,
                    color: AppColors.carbs,
                  ),
                  const SizedBox(height: 8),
                  _buildMacroBar(
                    label: 'Healthy Fats',
                    current: todayLog.totalFat,
                    target: plan.targetFatGrams,
                    color: AppColors.fats,
                  ),
                ],
              ),
            ),
          ],
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
