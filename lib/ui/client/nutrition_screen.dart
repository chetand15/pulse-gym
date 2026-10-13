import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/nutrition_model.dart';
import '../../core/services/nutrition_service.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionService>();
    final plan = nutrition.activePlan;
    final log = nutrition.todayLog;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition & Diet'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Calorie & Macro Target Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
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
                        const Text('Daily Calories Target', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${log.totalCalories}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.calories),
                            ),
                            Text(
                              ' / ${plan.targetCalories} kcal',
                              style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.calories.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_fire_department, color: AppColors.calories, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3 Macro Progress Columns
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroItem(
                        label: 'Protein',
                        current: log.totalProtein,
                        target: plan.targetProteinGrams,
                        color: AppColors.protein,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMacroItem(
                        label: 'Carbs',
                        current: log.totalCarbs,
                        target: plan.targetCarbsGrams,
                        color: AppColors.carbs,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMacroItem(
                        label: 'Fats',
                        current: log.totalFat,
                        target: plan.targetFatGrams,
                        color: AppColors.fats,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Water Tracker Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.water_drop, color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hydration Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        '${log.waterMl} ml / 3,000 ml',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.secondary, size: 32),
                  tooltip: 'Add 250ml',
                  onPressed: () => nutrition.addWater(250),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Meals Breakdown
          const Text(
            'Meals & Food Log',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildMealSection(context, nutrition, MealType.breakfast, 'Breakfast', Icons.wb_sunny_outlined),
          _buildMealSection(context, nutrition, MealType.lunch, 'Lunch', Icons.wb_twilight),
          _buildMealSection(context, nutrition, MealType.dinner, 'Dinner', Icons.nights_stay_outlined),
          _buildMealSection(context, nutrition, MealType.snack, 'Snacks & Supplements', Icons.apple_outlined),
        ],
      ),
    );
  }

  Widget _buildMacroItem({
    required String label,
    required double current,
    required double target,
    required Color color,
  }) {
    final percent = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          '${current.toStringAsFixed(0)}g / ${target.toStringAsFixed(0)}g',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 5,
            backgroundColor: AppColors.surfaceLight,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    NutritionService nutrition,
    MealType type,
    String title,
    IconData icon,
  ) {
    final meal = nutrition.todayLog.meals.firstWhere(
      (m) => m.type == type,
      orElse: () => MealLog(type: type, foods: []),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  '${meal.totalCalories} kcal',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            if (meal.foods.isNotEmpty) ...[
              const Divider(color: AppColors.divider, height: 20),
              ...meal.foods.map((food) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(
                              'P: ${food.proteinGrams}g • C: ${food.carbsGrams}g • F: ${food.fatGrams}g',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Text('${food.calories} kcal', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 18, color: AppColors.textMuted),
                        onPressed: () => nutrition.removeFoodFromMeal(type, food.id),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 36),
              ),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text('Add Food', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              onPressed: () => _showAddFoodDialog(context, nutrition, type),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog(BuildContext context, NutritionService nutrition, MealType type) {
    final commonFoods = nutrition.getCommonFoods();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Add Food Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...commonFoods.map((f) {
              return ListTile(
                title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${f.calories} kcal • P: ${f.proteinGrams}g  C: ${f.carbsGrams}g  F: ${f.fatGrams}g'),
                trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onTap: () {
                  nutrition.addFoodToMeal(type, f);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        );
      },
    );
  }
}
