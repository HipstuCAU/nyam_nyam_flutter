import 'package:nyam_nyam_flutter/models/meal.dart';

class MealsForDayModel {
  final DateTime date;
  final List<MealModel> meals;

  MealsForDayModel({
    required this.date,
    required this.meals,
  });
}
