import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/models/meal.dart';
import 'package:nyam_nyam_flutter/models/mealsByCampus.dart';
import 'package:nyam_nyam_flutter/models/mealsForDay.dart';

class ApiService {
  Future<List<MealsForWeek>> getMeals() async {
    final String response =
        await rootBundle.loadString('assets/jsons/CAU_Cafeteria_Menu.json');
    final Map<String, dynamic> decodedResponse = await json.decode(response);
    MealsByCampusModel seoulMealsInstances =
        MealsByCampusModel.SeoulfromJson(decodedResponse);
    MealsByCampusModel ansungMealsInstances =
        MealsByCampusModel.AnsungfromJson(decodedResponse);

    var mealsForWeekSeoul = getMealsForWeek(seoulMealsInstances);
    var mealsForWeekAnsung = getMealsForWeek(ansungMealsInstances);

    return [mealsForWeekSeoul, mealsForWeekAnsung];
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
              case "???????????????(310??? B4???)":
                restaurantType = RestaurantType.chamsulgi;
                break;
              case "???????????????(????????????308???)":
                restaurantType = RestaurantType.domitoryA;
                break;
              case "???????????????(????????????309???)":
                restaurantType = RestaurantType.domitoryB;
                break;
              case "????????????(303???B1???)":
                restaurantType = RestaurantType.student;
                break;
              case "???????????????(303???B1???)":
                restaurantType = RestaurantType.staff;
                break;
              case "????????????(cau eats)":
                restaurantType = RestaurantType.cauEats;
                break;
              case "(??????)????????????":
                restaurantType = RestaurantType.cauBurger;
                break;
              case "(??????)??????":
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
                case "??????":
                  mealType = MealType.korean;
                  break;
                case "??????":
                  mealType = MealType.western;
                  break;
                case "??????":
                  mealType = MealType.special;
                  break;
                case "????????????":
                  mealType = MealType.studentDinner;
                  break;
                case "??????":
                  mealType = MealType.ordinaryDinner;
                  break;
                case "??????1":
                  mealType = MealType.illpum1;
                  break;
                default:
                  mealType = MealType.korean;
                  break;
              }
              price = value['price'];
              menu = value['menu'].split("|");
              openType = menu == "??????????????????"
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

  MealsForWeek getMealsForWeek(MealsByCampusModel mealsByCampusModel) {
    Map<DateTime, List<MealModel>> mealsForWeek = {};
    List<MealModel> meals = getMealsByCampus(mealsByCampusModel);
    List<MealModel> mealsForDay = [];
    for (var element in meals) {
      if (mealsForWeek.containsKey(element.date)) {
        mealsForDay = mealsForWeek[element.date]!;
        mealsForDay.add(element);
        mealsForWeek[element.date] = mealsForDay;
      } else {
        mealsForDay.add(element);
        mealsForWeek[element.date] = mealsForDay;
      }
    }

    return mealsForWeek;
  }
}
