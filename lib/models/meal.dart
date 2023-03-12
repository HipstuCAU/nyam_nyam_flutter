import 'package:nyam_nyam_flutter/models/customType.dart';

class MealModel {
  final DateTime date;
  final List<DateTime> openTime;
  final RestaurantType restaurantType;
  final MealTime mealTime;
  final MealType mealType;
  final OpenType openType;
  final String price;
  final List<String> menu;

  MealModel({
    required this.date,
    required this.openTime,
    required this.restaurantType,
    required this.mealTime,
    required this.mealType,
    required this.openType,
    required this.menu,
    required this.price,
  });

  // MealModel.fromJson(Map<String, dynamic> json)
  //     : menu = json['menu'],
  //       price = json['price'],
  //       restaurant = json['cafetria'],
  //       date = json['date'],
  //       mealTime = json['mealTime'];
}
