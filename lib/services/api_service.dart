import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/models/meal.dart';
import 'package:nyam_nyam_flutter/models/mealsByCampus.dart';
import 'package:nyam_nyam_flutter/models/mealsForDay.dart';

class ApiService {
  Future<List<MealsByCampusModel>> getMeals() async {
    final String response =
        await rootBundle.loadString('assets/jsons/CAU_Cafeteria_Menu.json');
    final Map<String, dynamic> decodedResponse = await json.decode(response);
    MealsByCampusModel seoulMealsInstances =
        MealsByCampusModel.SeoulfromJson(decodedResponse);
    MealsByCampusModel ansungMealsInstances =
        MealsByCampusModel.AnsungfromJson(decodedResponse);

    getMealsByCampus(seoulMealsInstances);

    return [seoulMealsInstances, ansungMealsInstances];
  }

  List<MealModel> getMealsByCampus(MealsByCampusModel mealsByCampusModel) {
    List<MealModel> meals = [];

    for (int i = 0; i <= mealsByCampusModel.mealsForWeak.length; i++) {
      List<String> menu;
      String price;
      DateTime date;
      List<DateTime> openTime = [];
      MealTime mealTime;
      MealType mealType;
      OpenType openType;
      RestaurantType restaurantType;

      mealsByCampusModel.mealsForWeak.forEach((key, value) {
        date = DateTime.parse(key.replaceAll(".", ""));

        Map<String, dynamic> mealsByDay = value;
        mealsByDay.forEach((key, value) {
          switch (key) {
            case "0":
              mealTime = MealTime.breakfase;
              break;
            case "1":
              mealTime = MealTime.lunch;
              break;
            case "2":
              mealTime = MealTime.dinner;
              break;
            default:
              mealTime = MealTime.breakfase;
          }
          Map<String, dynamic> mealsByTime = value;
          mealsByTime.forEach((key, value) {
            switch (key) {
              case "참슬기식당(310관 B4층)":
                restaurantType = RestaurantType.chamsulgi;
                break;
              case "생활관식당(블루미르308관)":
                restaurantType = RestaurantType.domitoryA;
                break;
              case "생활관식당(블루미르309관)":
                restaurantType = RestaurantType.domitoryB;
                break;
              case "학생식당(303관B1층)":
                restaurantType = RestaurantType.student;
                break;
              case "교직원식당(303관B1층)":
                restaurantType = RestaurantType.staff;
                break;
              case "카우잇츠(cau eats)":
                restaurantType = RestaurantType.cauEats;
                break;
              case "(안성)카우버거":
                restaurantType = RestaurantType.cauBurger;
                break;
              case "(안성)라면":
                restaurantType = RestaurantType.ramen;
                break;
              default:
                restaurantType = RestaurantType.chamsulgi;
                break;
            }
            Map<String, dynamic> mealsByType = value;
            mealsByType.forEach((key, value) {
              var tmpMealType = key.split("(");
              if (tmpMealType.length > 1) {
                key = tmpMealType[1].replaceAll(')', '');
              }

              switch (key) {
                case "한식":
                  mealType = MealType.korean;
                  break;
                case "양식":
                  mealType = MealType.western;
                  break;
                case "특식":
                  mealType = MealType.special;
                  break;
                case "학생석식":
                  mealType = MealType.studentDinner;
                  break;
                case "석식":
                  mealType = MealType.ordinaryDinner;
                  break;
                case "일품1":
                  mealType = MealType.illpum1;
                  break;
                default:
                  mealType = MealType.korean;
                  break;
              }
              price = value['price'];
              menu = value['menu'].split("|");
              openType = menu == "주말운영없음"
                  ? OpenType.closeOnWeekends
                  : OpenType.everyday;

              if (value['time'] != null) {
                openTime = [];
                var tmpOpenTimeList = value['time'].split('~');
                openTime.add(DateFormat("hh:mm").parse(tmpOpenTimeList[0]));
                openTime.add(DateFormat("hh:mm").parse(tmpOpenTimeList[1]));
              }

              MealModel meal = MealModel(
                date: date,
                openTime: openTime,
                restaurantType: restaurantType,
                mealTime: mealTime,
                mealType: mealType,
                openType: openType,
                menu: menu,
                price: price,
              );
              meals.add(meal);
            });
          });
        });
      });
    }
    return meals;
  }

  List<MealsForDayModel> getMealsForWeek(
      MealsByCampusModel mealsByCampusModel) {
    List<MealsForDayModel> mealsForWeek = [];
    getMealsByCampus(mealsByCampusModel);
    return mealsForWeek;
  }
}
