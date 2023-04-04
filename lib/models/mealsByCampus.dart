class MealsByCampusModel {
  final Map<String, dynamic> seoulMealsForWeak;
  final Map<String, dynamic> ansungMealsForWeak;

  MealsByCampusModel.fromJson(Map<String, dynamic> json)
      : seoulMealsForWeak = json['0'],
        ansungMealsForWeak = json['1'];
}
