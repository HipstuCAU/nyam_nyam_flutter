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
  breakfast,
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

enum OpenStatusType {
  notRunning,
  preparing,
  running,
  closed,
}

typedef MealsForWeek = Map<String, MealsForDay>;
typedef MealsForDay = List<MealModel>;
