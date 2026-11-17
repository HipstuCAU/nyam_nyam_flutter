class MealsByCampusModel {
  final Map<String, dynamic> seoulMeals;
  final Map<String, dynamic> ansungMeals;

  MealsByCampusModel.fromJson(Map<String, dynamic> json)
    : seoulMeals = json['0'] as Map<String, dynamic>? ?? {},
      ansungMeals = json['1'] as Map<String, dynamic>? ?? {};
}
