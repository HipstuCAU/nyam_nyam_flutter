import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/models/meal.dart';
import 'package:nyam_nyam_flutter/models/mealsByCampus.dart';

class ApiService {
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static const _restaurantTypes = {
    '참슬기식당(310관 B4층)': RestaurantType.chamsulgi,
    '생활관식당(블루미르308관)': RestaurantType.domitoryA,
    '생활관식당(블루미르309관)': RestaurantType.domitoryB,
    '학생식당(303관B1층)': RestaurantType.student,
    '교직원식당(303관B1층)': RestaurantType.staff,
    'University Club(102관11층)': RestaurantType.universityClub,
    '카우잇츠(cau eats)': RestaurantType.cauEats,
    '(안성)카우버거': RestaurantType.cauBurger,
    '(다빈치)카우버거': RestaurantType.cauBurger,
    '(안성)라면': RestaurantType.ramen,
    '(다빈치)라면': RestaurantType.ramen,
  };

  Future<Map<String, dynamic>> getJsonFromFirebase() async {
    final response = await firestore
        .collection('CAU_Haksik')
        .doc('CAU_Cafeteria_Menu')
        .get();
    return response.data() ?? {};
  }

  Future<List<Map<String, List<MealModel>>>> getMeals(
    Map<String, dynamic> data,
  ) async {
    if (data.isEmpty) return [];
    return getMealsForWeek(MealsByCampusModel.fromJson(data));
  }

  List<List<MealModel>> getMealsByCampus(
    MealsByCampusModel mealsByCampusModel,
  ) {
    List<MealModel> getMealsForOneCampus(Map<String, dynamic> days) {
      final meals = <MealModel>[];
      days.forEach((dateKey, dayValue) {
        final date = DateTime.parse(dateKey.replaceAll('.', ''));
        final mealsByDay = dayValue as Map<String, dynamic>;
        mealsByDay.forEach((timeKey, timeValue) {
          final mealTime = switch (timeKey) {
            '1' => MealTime.lunch,
            '2' => MealTime.dinner,
            _ => MealTime.breakfast,
          };
          final mealsByTime = timeValue as Map<String, dynamic>;
          mealsByTime.forEach((restaurantName, restaurantValue) {
            final restaurantType = _restaurantTypes[restaurantName];
            // An unknown restaurant must not appear under another restaurant.
            if (restaurantType == null) return;
            final mealsByType = restaurantValue as Map<String, dynamic>;
            mealsByType.forEach((typeKey, mealValue) {
              final value = mealValue as Map<String, dynamic>;
              final menu = (value['menu'] as String? ?? '')
                  .split('|')
                  .map((item) => item.trim())
                  .where((item) => item.isNotEmpty)
                  .toList();
              if (menu.isEmpty) return;

              final typeParts = typeKey.split('(');
              final type = typeParts.length > 1
                  ? typeParts[1].replaceAll(')', '')
                  : typeKey;
              final mealType = switch (type) {
                '양식' => MealType.western,
                '특식' => MealType.special,
                '학생석식' => MealType.studentDinner,
                '석식' => MealType.ordinaryDinner,
                '일품1' => MealType.illpum1,
                _ => MealType.korean,
              };
              final openType = switch (menu.length == 1 ? menu.single : null) {
                '주말운영없음' => OpenType.closeOnWeekends,
                '운영없음' || '휴무' => OpenType.closed,
                _ => OpenType.everyday,
              };

              meals.add(
                MealModel(
                  date: date,
                  openTime: _parseOpenTime(value['time'] as String?),
                  restaurantType: restaurantType,
                  mealTime: mealTime,
                  mealType: mealType,
                  openType: openType,
                  menu: menu,
                  price: value['price'] as String? ?? '',
                ),
              );
            });
          });
        });
      });
      return meals;
    }

    return [
      getMealsForOneCampus(mealsByCampusModel.seoulMeals),
      getMealsForOneCampus(mealsByCampusModel.ansungMeals),
    ];
  }

  List<DateTime> _parseOpenTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    final parts = raw.split('~');
    if (parts.length > 2) return [];
    final format = DateFormat('HH:mm');
    try {
      return parts.map((part) => format.parseStrict(part.trim())).toList();
    } on FormatException {
      return [];
    }
  }

  List<MealsForWeek> getMealsForWeek(MealsByCampusModel mealsByCampusModel) {
    final format = DateFormat('yyyy-MM-dd');
    return getMealsByCampus(mealsByCampusModel).map((campusMeals) {
      final mealsForWeek = <String, List<MealModel>>{};
      for (final meal in campusMeals) {
        final dateKey = format.format(meal.date);
        mealsForWeek.putIfAbsent(dateKey, () => []).add(meal);
      }
      return mealsForWeek;
    }).toList();
  }
}
