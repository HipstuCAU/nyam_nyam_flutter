class MealsByCampusModel {
  final Map<String, dynamic> seoulMeals;
  final Map<String, dynamic> ansungMeals;

  MealsByCampusModel.fromJson(Map<String, dynamic> json)
      : seoulMeals = json['0'],
        ansungMeals = json['1'];
}
