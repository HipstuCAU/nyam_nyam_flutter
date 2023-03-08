import 'package:nyam_nyam_flutter/models/customType.dart';

class MealModel {
  final String menu, price;
  final RestaurantType restaurant;
  final DateTime date;
  final MealTime mealTime;

  MealModel.fromJson(Map<String, dynamic> json)
      : menu = json['menu'],
        price = json['price'],
        restaurant = json['cafetria'],
        date = json['date'],
        mealTime = json['mealTime'];
}
