import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/theme_service.dart';
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

  // Sample weekly activity (Mon - Sun, true = worked out)
  final List<Map<String, dynamic>> _weeklyActivity = [
    {'day': 'M', 'done': true},
    {'day': 'T', 'done': true},
    {'day': 'W', 'done': true},
    {'day': 'T', 'done': false},
    {'day': 'F', 'done': true},
    {'day': 'S', 'done': true},
    {'day': 'S', 'done': false},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeService>();
    final auth = context.watch<AuthService>();
    final workout = context.watch<WorkoutService>();
    final nutrition = context.watch<NutritionService>();
    final trainer = context.watch<TrainerService>();

    final user = auth.currentUser;
    final todayLog = nutrition.todayLog;
    final plan = nutrition.activePlan;
    final primary = theme.primaryColor;

    // Retrieve PPL Split Template
    final pplTemplate = trainer.templates.isNotEmpty ? trainer.templates.first : null;
    final availableDays = pplTemplate?.days ?? [];
    final selectedWorkoutDay = availableDays.isNotEmpty && _selectedDayIndex < availableDays.length
        ? availableDays[_selectedDayIndex]
        : null;

    final calPercent = (todayLog.totalCalories / plan.targetCalories).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primary.withOpacity(0.2),
              radius: 18,
              child: Text(
                user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'A',
                style: TextStyle(fontWeight: FontWeight.bold, color: primary),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Athlete',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${theme.currentPalette.emoji} ${theme.currentPalette.name} Theme',
                  style: TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Theme Palette Picker Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary.withOpacity(0.5)),
              ),
              child: Icon(Icons.palette_outlined, color: primary, size: 18),
            ),
            tooltip: 'Choose Color Theme',
            onPressed: () => _showThemePickerSheet(context, theme),
          ),
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
            // 1. Weekly Consistency Streak Tracker
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withOpacity(0.25)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          const Text(
                            '5-DAY WORKOUT STREAK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '85% Consistency',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 7-Day Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _weeklyActivity.map((item) {
                      final isDone = item['done'] as bool;
                      return Column(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDone ? primary : AppColors.surfaceLight,
                              shape: BoxShape.circle,
                              boxShadow: isDone
                                  ? [
                                      BoxShadow(
                                        color: primary.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              isDone ? Icons.check : Icons.circle_outlined,
                              size: 18,
                              color: isDone ? Colors.black : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['day'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDone ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Quick Stat Counters
            Row(
              children: [
                Expanded(
                  child: _buildGlassCard(
                    title: 'Workouts',
                    value: '${workout.recentWorkoutLogs.length + 5}',
                    subtitle: 'This Month',
                    icon: Icons.fitness_center,
                    accentColor: primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGlassCard(
                    title: 'Hydration',
                    value: '${(todayLog.waterMl / 1000).toStringAsFixed(1)}L',
                    subtitle: 'Target: 3.0L',
                    icon: Icons.water_drop,
                    accentColor: theme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 3. PUSH / PULL / LEGS Day Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Workout Routine',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Choose Today’s Split',
                  style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _buildSplitChip(index: 0, title: '🏋️ Push Day', subtitle: 'Chest & Tris', activeColor: primary),
                const SizedBox(width: 8),
                _buildSplitChip(index: 1, title: '🧗 Pull Day', subtitle: 'Back & Bis', activeColor: primary),
                const SizedBox(width: 8),
                _buildSplitChip(index: 2, title: '🦵 Leg Day', subtitle: 'Quads & Glutes', activeColor: primary),
              ],
            ),
            const SizedBox(height: 14),

            // 4. Hero Workout Split Card (Neon border & glowing details)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.cardColor,
                    theme.cardColor.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withOpacity(0.5), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.12),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                          color: primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedDayIndex == 0
                              ? 'PUSH FOCUS • CHEST & DELTS'
                              : (_selectedDayIndex == 1
                                  ? 'PULL FOCUS • LATS & POSTERIOR'
                                  : 'LEG FOCUS • QUAD & HAMSTRING POWER'),
                          style: TextStyle(
                            color: primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department, color: primary, size: 16),
                          const SizedBox(width: 3),
                          const Text('~450 kcal', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        ],
                      ),
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

                  // Exercises Pills
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
                            '${ex.exerciseName} (${ex.targetSets}s)',
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
                      backgroundColor: primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(workout.isWorkoutActive ? Icons.timer : Icons.play_arrow),
                    label: Text(
                      workout.isWorkoutActive
                          ? 'RESUME SESSION (${workout.formattedDuration})'
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
                      widget.onNavigateTab(1); // Switch to Workout tab
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Nutrition & Macro Rings Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Nutrition",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => widget.onNavigateTab(2),
                  child: Text('View Details →', style: TextStyle(color: primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.cardColor,
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
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primary),
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
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 54,
                            height: 54,
                            child: CircularProgressIndicator(
                              value: calPercent,
                              strokeWidth: 6,
                              backgroundColor: AppColors.surfaceLight,
                              color: primary,
                            ),
                          ),
                          Text(
                            '${(calPercent * 100).toInt()}%',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
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
            const SizedBox(height: 24),

            // 6. Quick Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.water_drop, color: AppColors.secondary, size: 16),
                    label: const Text('+250ml Water', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    onPressed: () {
                      nutrition.addWater(250);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('💧 Logged 250ml water!')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(Icons.palette_outlined, color: primary, size: 16),
                    label: const Text('Change Color', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    onPressed: () => _showThemePickerSheet(context, theme),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitChip({required int index, required String title, required String subtitle, required Color activeColor}) {
    final isSelected = _selectedDayIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDayIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.18) : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.divider,
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
                  color: isSelected ? activeColor : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
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

  Widget _buildGlassCard({
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

  // Interactive Bottom Sheet to switch color palettes
  void _showThemePickerSheet(BuildContext context, ThemeService theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎨 Choose Dashboard Color',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your favorite aesthetic. The entire app adapts instantly.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),

              // 6 Palettes Grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ThemeService.availablePalettes.map((palette) {
                  final isSelected = theme.currentPalette.id == palette.id;
                  return GestureDetector(
                    onTap: () {
                      theme.setPalette(palette);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: palette.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? palette.primary : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: palette.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${palette.emoji} ${palette.name}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isSelected ? palette.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }
}
