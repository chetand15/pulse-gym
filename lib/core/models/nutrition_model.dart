class FoodItem {
  final String id;
  final String name;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final String serving;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.serving = '1 serving',
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      proteinGrams: (map['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (map['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (map['fatGrams'] as num?)?.toDouble() ?? 0.0,
      serving: map['serving'] ?? '1 serving',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'serving': serving,
    };
  }
}

enum MealType { breakfast, lunch, dinner, snack }

class MealLog {
  final MealType type;
  final List<FoodItem> foods;

  MealLog({required this.type, required this.foods});

  int get totalCalories => foods.fold(0, (sum, f) => sum + f.calories);
  double get totalProtein => foods.fold(0.0, (sum, f) => sum + f.proteinGrams);
  double get totalCarbs => foods.fold(0.0, (sum, f) => sum + f.carbsGrams);
  double get totalFat => foods.fold(0.0, (sum, f) => sum + f.fatGrams);

  factory MealLog.fromMap(Map<String, dynamic> map) {
    MealType type;
    switch (map['type']) {
      case 'breakfast':
        type = MealType.breakfast;
        break;
      case 'lunch':
        type = MealType.lunch;
        break;
      case 'dinner':
        type = MealType.dinner;
        break;
      default:
        type = MealType.snack;
    }

    return MealLog(
      type: type,
      foods: (map['foods'] as List<dynamic>? ?? [])
          .map((f) => FoodItem.fromMap(f as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'foods': foods.map((f) => f.toMap()).toList(),
    };
  }
}

class DailyNutritionLog {
  final String id;
  final String userId;
  final String date; // Format: YYYY-MM-DD
  final List<MealLog> meals;
  final int waterMl;

  DailyNutritionLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.meals,
    this.waterMl = 0,
  });

  int get totalCalories => meals.fold(0, (sum, m) => sum + m.totalCalories);
  double get totalProtein => meals.fold(0.0, (sum, m) => sum + m.totalProtein);
  double get totalCarbs => meals.fold(0.0, (sum, m) => sum + m.totalCarbs);
  double get totalFat => meals.fold(0.0, (sum, m) => sum + m.totalFat);

  factory DailyNutritionLog.fromMap(Map<String, dynamic> map, String id) {
    return DailyNutritionLog(
      id: id,
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      meals: (map['meals'] as List<dynamic>? ?? [])
          .map((m) => MealLog.fromMap(m as Map<String, dynamic>))
          .toList(),
      waterMl: map['waterMl'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'meals': meals.map((m) => m.toMap()).toList(),
      'waterMl': waterMl,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }
}

class NutritionPlanModel {
  final String id;
  final String clientId;
  final String trainerId;
  final int targetCalories;
  final double targetProteinGrams;
  final double targetCarbsGrams;
  final double targetFatGrams;
  final String notes;

  NutritionPlanModel({
    required this.id,
    required this.clientId,
    required this.trainerId,
    required this.targetCalories,
    required this.targetProteinGrams,
    required this.targetCarbsGrams,
    required this.targetFatGrams,
    this.notes = '',
  });

  factory NutritionPlanModel.fromMap(Map<String, dynamic> map, String id) {
    return NutritionPlanModel(
      id: id,
      clientId: map['clientId'] ?? '',
      trainerId: map['trainerId'] ?? '',
      targetCalories: map['targetCalories'] ?? 2000,
      targetProteinGrams: (map['targetProteinGrams'] as num?)?.toDouble() ?? 150.0,
      targetCarbsGrams: (map['targetCarbsGrams'] as num?)?.toDouble() ?? 200.0,
      targetFatGrams: (map['targetFatGrams'] as num?)?.toDouble() ?? 65.0,
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'trainerId': trainerId,
      'targetCalories': targetCalories,
      'targetProteinGrams': targetProteinGrams,
      'targetCarbsGrams': targetCarbsGrams,
      'targetFatGrams': targetFatGrams,
      'notes': notes,
    };
  }
}
