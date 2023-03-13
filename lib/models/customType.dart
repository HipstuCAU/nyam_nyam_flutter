import 'package:nyam_nyam_flutter/models/meal.dart';

enum RestaurantType {
  chamsulgi,
  domitoryA,
  domitoryB,
  student,
  staff,
  cauEats,
  cauBurger,
  ramen,
}

enum CampusType {
  seoul,
  ansung,
}

enum MealTime {
  breakfase,
  lunch,
  dinner,
}

enum OpenType {
  closeOnWeekends,
  everyday,
}

enum MealType {
  western,
  korean,
  special,
  studentDinner,
  ordinaryDinner,
  illpum1,
}

typedef MealsForWeek = Map<DateTime, MealsForDay>;
typedef MealsForDay = List<MealModel>;
