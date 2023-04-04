import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/models/meal.dart';
import 'package:nyam_nyam_flutter/models/mealsByCampus.dart';

class ApiService {
  final firestore = FirebaseFirestore.instance;

  Future<List<bool>> getUploadedSevenDatesBool(
      CampusType campus, List<String> dates) async {
    var response = await firestore
        .collection('CAU_Haksik')
        .doc("CAU_Cafeteria_Menu")
        .get();
    var data = response.data();

    List<bool> isUploadedDates = [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ];

    if (data != null) {
      MealsByCampusModel seoulMealsInstances =
          MealsByCampusModel.SeoulfromJson(data);
      MealsByCampusModel ansungMealsInstances =
          MealsByCampusModel.AnsungfromJson(data);

      var mealsForWeek = campus == CampusType.seoul
          ? getMealsForWeek(seoulMealsInstances)
          : getMealsForWeek(ansungMealsInstances);

      for (int i = 0; i < 7; i++) {
        if (mealsForWeek[dates[i]] != null) {
          isUploadedDates[i] = true;
        } else {
          isUploadedDates[i] = false;
        }
      }
    }

    return isUploadedDates;
  }

  Future<List<MealModel>> getMeals(CampusType campus, String date) async {
    var response = await firestore
        .collection('CAU_Haksik')
        .doc("CAU_Cafeteria_Menu")
        .get();
    var data = response.data();

    List<MealModel> meals = [];

    if (data != null) {
      MealsByCampusModel mealsInstances = MealsByCampusModel.fromJson(data);

      var mealsForWeek = getMealsForWeek(mealsInstances);

      if (mealsForWeek[date] != null) {
        meals = mealsForWeek[date]!.where((element) {
          return element.date == DateFormat('yyyy-MM-dd').parse(date);
        }).toList();
      }
    }

    return meals;
  }

  List<List<MealModel>> getMealsByCampus(
      MealsByCampusModel mealsByCampusModel) {
    List<MealModel> seoulMeals = [];
    List<MealModel> ansungMeals = [];
    List<List<MealModel>> meals = [];
    List<String> menu;
    String price;
    DateTime date;
    List<DateTime> openTime = [];
    MealTime mealTime;
    MealType mealType;
    OpenType openType;
    RestaurantType restaurantType;

    mealsByCampusModel.ansungMealsForWeak.forEach((key, value) {
      date = DateTime.parse(key.replaceAll(".", ""));

      Map<String, dynamic> mealsByDay = value;
      mealsByDay.forEach((key, value) {
        switch (key) {
          case "0":
            mealTime = MealTime.breakfast;
            break;
          case "1":
            mealTime = MealTime.lunch;
            break;
          case "2":
            mealTime = MealTime.dinner;
            break;
          default:
            mealTime = MealTime.breakfast;
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
            var menuFullString = value['menu'];
            if (menuFullString != "") {
              menu = menuFullString.split("|");
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
              seoulMeals.add(meal);
            }
          });
        });
      });
    });

    mealsByCampusModel.seoulMealsForWeak.forEach((key, value) {
      date = DateTime.parse(key.replaceAll(".", ""));

      Map<String, dynamic> mealsByDay = value;
      mealsByDay.forEach((key, value) {
        switch (key) {
          case "0":
            mealTime = MealTime.breakfast;
            break;
          case "1":
            mealTime = MealTime.lunch;
            break;
          case "2":
            mealTime = MealTime.dinner;
            break;
          default:
            mealTime = MealTime.breakfast;
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
            var menuFullString = value['menu'];
            if (menuFullString != "") {
              menu = menuFullString.split("|");
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
              ansungMeals.add(meal);
            }
          });
        });
      });
    });

    meals.add(seoulMeals);
    meals.add(ansungMeals);

    return meals;
  }

  MealsForWeek getMealsForWeek(MealsByCampusModel mealsByCampusModel) {
    Map<String, List<MealModel>> mealsForWeek = {};
    List<MealModel> meals = getMealsByCampus(mealsByCampusModel);
    List<MealModel> mealsForDay = [];
    for (var element in meals) {
      if (mealsForWeek.containsKey(element.date)) {
        mealsForDay = mealsForWeek[element.date]!;
        mealsForDay.add(element);
        mealsForWeek[element.date.toString().substring(0, 10)] = mealsForDay;
      } else {
        mealsForDay.add(element);
        mealsForWeek[element.date.toString().substring(0, 10)] = mealsForDay;
      }
    }
    return mealsForWeek;
  }
}
