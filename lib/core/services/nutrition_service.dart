import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/nutrition_model.dart';

class NutritionService extends ChangeNotifier {
  bool get _hasFirebase => Firebase.apps.isNotEmpty;
  FirebaseFirestore? get _firestore => _hasFirebase ? FirebaseFirestore.instance : null;
  final Uuid _uuid = const Uuid();

  // Active Plan (Trainer Assigned or Default)
  NutritionPlanModel _activePlan = NutritionPlanModel(
    id: 'default_plan',
    clientId: 'client_demo_1',
    trainerId: 'trainer_demo_1',
    targetCalories: 2400,
    targetProteinGrams: 180,
    targetCarbsGrams: 260,
    targetFatGrams: 70,
    notes: 'Focus on high protein with every meal and steady hydration.',
  );

  // Today's Log
  DailyNutritionLog? _todayLog;

  NutritionPlanModel get activePlan => _activePlan;
  DailyNutritionLog get todayLog {
    if (_todayLog == null) {
      final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _todayLog = DailyNutritionLog(
        id: 'log_$dateKey',
        userId: 'client_demo_1',
        date: dateKey,
        meals: [
          MealLog(type: MealType.breakfast, foods: [
            FoodItem(id: '1', name: 'Oatmeal & Whey Protein', calories: 420, proteinGrams: 35, carbsGrams: 55, fatGrams: 7),
            FoodItem(id: '2', name: 'Banana', calories: 105, proteinGrams: 1.3, carbsGrams: 27, fatGrams: 0.3),
          ]),
          MealLog(type: MealType.lunch, foods: [
            FoodItem(id: '3', name: 'Grilled Chicken Breast (200g)', calories: 330, proteinGrams: 62, carbsGrams: 0, fatGrams: 7),
            FoodItem(id: '4', name: 'Brown Rice (1 cup)', calories: 215, proteinGrams: 5, carbsGrams: 45, fatGrams: 1.8),
          ]),
          MealLog(type: MealType.dinner, foods: []),
          MealLog(type: MealType.snack, foods: []),
        ],
        waterMl: 1750,
      );
    }
    return _todayLog!;
  }

  void addFoodToMeal(MealType type, FoodItem food) {
    final log = todayLog;
    final meal = log.meals.firstWhere((m) => m.type == type, orElse: () {
      final newMeal = MealLog(type: type, foods: []);
      log.meals.add(newMeal);
      return newMeal;
    });

    meal.foods.add(food);
    notifyListeners();
    _syncTodayLog();
  }

  void removeFoodFromMeal(MealType type, String foodId) {
    final log = todayLog;
    final meal = log.meals.firstWhere((m) => m.type == type);
    meal.foods.removeWhere((f) => f.id == foodId);
    notifyListeners();
    _syncTodayLog();
  }

  void addWater(int ml) {
    final log = todayLog;
    _todayLog = DailyNutritionLog(
      id: log.id,
      userId: log.userId,
      date: log.date,
      meals: log.meals,
      waterMl: log.waterMl + ml,
    );
    notifyListeners();
    _syncTodayLog();
  }

  void updatePlan(NutritionPlanModel newPlan) {
    _activePlan = newPlan;
    notifyListeners();
  }

  Future<void> _syncTodayLog() async {
    if (!_hasFirebase) return;
    try {
      if (_todayLog != null) {
        await _firestore
            ?.collection('nutrition_logs')
            .doc(_todayLog!.id)
            .set(_todayLog!.toMap());
      }
    } catch (e) {
      debugPrint('Sync nutrition log notice: $e');
    }
  }

  List<FoodItem> getCommonFoods() {
    return [
      FoodItem(id: _uuid.v4(), name: 'Grilled Chicken Breast (150g)', calories: 247, proteinGrams: 46.5, carbsGrams: 0, fatGrams: 5.4),
      FoodItem(id: _uuid.v4(), name: 'Eggs (2 large)', calories: 144, proteinGrams: 12.6, carbsGrams: 0.8, fatGrams: 9.6),
      FoodItem(id: _uuid.v4(), name: 'Whey Protein Scoop (30g)', calories: 120, proteinGrams: 24, carbsGrams: 3, fatGrams: 1.5),
      FoodItem(id: _uuid.v4(), name: 'Cooked White Rice (1 cup)', calories: 205, proteinGrams: 4.2, carbsGrams: 44.5, fatGrams: 0.4),
      FoodItem(id: _uuid.v4(), name: 'Greek Yogurt 0% (200g)', calories: 120, proteinGrams: 20, carbsGrams: 7, fatGrams: 0),
      FoodItem(id: _uuid.v4(), name: 'Peanut Butter (2 tbsp)', calories: 190, proteinGrams: 8, carbsGrams: 7, fatGrams: 16),
      FoodItem(id: _uuid.v4(), name: 'Salmon Fillet (180g)', calories: 370, proteinGrams: 36, carbsGrams: 0, fatGrams: 24),
    ];
  }
}
