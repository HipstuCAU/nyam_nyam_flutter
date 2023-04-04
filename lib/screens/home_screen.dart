import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'dart:ui' as ui;
import 'package:intl/date_symbol_data_local.dart';
import 'package:nyam_nyam_flutter/models/meal.dart';
import 'package:nyam_nyam_flutter/screens/setting_screen.dart';
import 'package:nyam_nyam_flutter/services/api_service.dart';
import 'package:nyam_nyam_flutter/widgets/menu_widget.dart';
import 'package:nyam_nyam_flutter/widgets/restaurantPicker_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static CampusType entryPoint = CampusType.seoul;
  static List<bool> isSelectedRestaurant = [
    true,
    false,
    false,
    false,
    false,
  ];
  static PageController pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.9,
  );
  static AutoScrollController autoScrollController = AutoScrollController();
  static List<String> seoulRestaurantName = [
    '참슬기',
    '생활관A',
    '생활관B',
    '학생식당',
    '교직원'
  ];
  static List<String> ansungRestaurantName = [
    '카우이츠',
    '카우버거',
    '라면',
  ];

  static List<bool> isSelectedDate = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  static late SharedPreferences preferences;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var sevenDays = [];
  var sevenDaysOfWeek = [];
  List<String> sevenDateTime = [];
  Map<String, String> sevenDates = {};

  var currentPageIndex = 0;

  late Future<List<MealModel>> meals;

  late Future<List<bool>> isUploadedDates;

  Future initPreferences() async {
    HomeScreen.preferences = await SharedPreferences.getInstance();
    final favoriteCampus = HomeScreen.preferences.getString('favoriteCampus');
    final sortedSeoulRestaurants =
        HomeScreen.preferences.getStringList('sortedSeoulRestaurants');
    final sortedAnsungRestaurants =
        HomeScreen.preferences.getStringList('sortedAnsungRestaurants');
    setState(() {
      if (favoriteCampus != null) {
        if (favoriteCampus == "서울") {
          HomeScreen.entryPoint = CampusType.seoul;
        } else {
          HomeScreen.entryPoint = CampusType.ansung;
        }
      } else {
        HomeScreen.preferences.setString('favoriteCampus', '서울');
      }

      if (sortedSeoulRestaurants != null) {
        HomeScreen.seoulRestaurantName = sortedSeoulRestaurants;
      } else {
        HomeScreen.preferences.setStringList('sortedSeoulRestaurants', [
          '참슬기',
          '생활관A',
          '생활관B',
          '학생식당',
          '교직원',
        ]);
      }

      if (sortedAnsungRestaurants != null) {
        HomeScreen.ansungRestaurantName = sortedAnsungRestaurants;
      } else {
        HomeScreen.preferences.setStringList('sortedAnsungRestaurants', [
          '카우이츠',
          '카우버거',
          '라면',
        ]);
      }
      isUploadedDates = ApiService()
          .getUploadedSevenDatesBool(HomeScreen.entryPoint, sevenDateTime);
      meals = ApiService().getMeals(HomeScreen.entryPoint,
          sevenDateTime[HomeScreen.isSelectedDate.indexOf(true)]);
    });
  }

  @override
  void initState() {
    super.initState();
    initPreferences();
    get7daysFromToday();
    isUploadedDates = ApiService()
        .getUploadedSevenDatesBool(HomeScreen.entryPoint, sevenDateTime);
    meals = ApiService().getMeals(HomeScreen.entryPoint,
        sevenDateTime[HomeScreen.isSelectedDate.indexOf(true)]);
  }

  Map<String, String> get7daysFromToday() {
    var today = DateTime.now().add(const Duration(hours: 0));
    for (int i = 0; i < 7; i++) {
      initializeDateFormatting();
      DateTime date = today.subtract(Duration(days: -i));
      sevenDateTime.add(DateFormat('yyyy-MM-dd').format(date));
      sevenDays.add(int.parse(DateFormat('dd').format(date)).toString());
      sevenDaysOfWeek.add(DateFormat.E('ko_KR').format(date));
      sevenDates[sevenDaysOfWeek[i]] = sevenDays[i];
    }
    return sevenDates;
  }

  void touchUpToInsideToSelectDate(int index, bool isUploadedDate) {
    setState(() {
      if (isUploadedDate) {
        if (HomeScreen.isSelectedDate[index] == true) {
          return;
        } else {
          HomeScreen.isSelectedDate = [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          HomeScreen.isSelectedDate[index] = true;
        }
        getMealsByDate();
        HomeScreen.pageController = PageController(
          initialPage: HomeScreen.isSelectedRestaurant.indexOf(true),
          viewportFraction: 0.9,
        );
      } else {
        showToast();
      }
    });
  }

  void showToast() {
    Fluttertoast.showToast(
      msg: "😂 아직 식단이 업데이트 되지 않았어요",
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFF4E5968).withOpacity(0.98),
      fontSize: 16,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void getMealsByDate() {
    meals = ApiService().getMeals(HomeScreen.entryPoint,
        sevenDateTime[HomeScreen.isSelectedDate.indexOf(true)]);
  }

  void resetRestaurantPicekr() {
    HomeScreen.isSelectedRestaurant = HomeScreen.entryPoint == CampusType.seoul
        ? [
            true,
            false,
            false,
            false,
            false,
          ]
        : [
            true,
            false,
            false,
          ];
    HomeScreen.pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: NyamColors.gradientBG,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 30,
                left: 10,
                right: 10,
                bottom: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: TextButton.icon(
                      onPressed: (() {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoActionSheet(
                            title: const Text("캠퍼스를 선택해주세요."),
                            actions: <Widget>[
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  setState(() {
                                    HomeScreen.entryPoint = CampusType.seoul;
                                    Navigator.pop(context, 'Cancel');
                                    HomeScreen.isSelectedRestaurant = [
                                      true,
                                      false,
                                      false,
                                      false,
                                      false,
                                    ];
                                    getMealsByDate();
                                  });
                                },
                                child: const Text(
                                  "서울캠퍼스",
                                ),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  setState(() {
                                    HomeScreen.entryPoint = CampusType.ansung;
                                    Navigator.pop(context, 'Cancel');
                                    HomeScreen.isSelectedRestaurant = [
                                      true,
                                      false,
                                      false,
                                    ];
                                    getMealsByDate();
                                  });
                                },
                                child: const Text(
                                  "안성캠퍼스",
                                ),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(context, 'Cancel');
                              },
                              child: const Text("취소"),
                            ),
                          ),
                        );
                      }),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: NyamColors.customGrey,
                        size: 35,
                      ),
                      label: Text(
                        HomeScreen.entryPoint == CampusType.seoul
                            ? "서울캠퍼스"
                            : "안성캠퍼스",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = const Offset(1, 0);
                            var end = Offset.zero;
                            var curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end).chain(
                              CurveTween(
                                curve: curve,
                              ),
                            );
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SettingScreen(),
                        ),
                      );
                      setState(() {
                        // getMealsByDate();
                        resetRestaurantPicekr();
                        HomeScreen.pageController = PageController(
                            initialPage: 0, viewportFraction: 0.9);
                      });
                    },
                    icon: const Icon(Icons.settings),
                    color: NyamColors.customGrey,
                    iconSize: 25,
                  )
                ],
              ),
            ),
            Container(
              height: 10,
              color: NyamColors.customSkyBlue,
            ),
            Container(
              color: NyamColors.customSkyBlue,
              height: 45,
              child: FutureBuilder(
                future: isUploadedDates,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      Color textColor = NyamColors.grey50;
                      if (snapshot.data![index] == true) {
                        if (HomeScreen.isSelectedDate[index]) {
                          textColor = Colors.white;
                        } else {
                          textColor = NyamColors.customBlack;
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            touchUpToInsideToSelectDate(
                                index, snapshot.data![index]);
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 28,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 14,
                            child: Container(
                              decoration: BoxDecoration(
                                color: HomeScreen.isSelectedDate[index]
                                    ? NyamColors.cauBlue
                                    : NyamColors.customSkyBlue,
                                borderRadius: BorderRadius.circular(15),
                                border: index == 0
                                    ? Border.all(
                                        width: 1,
                                        color: NyamColors.cauBlue,
                                      )
                                    : Border.all(
                                        width: 0,
                                        color: NyamColors.customSkyBlue,
                                      ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 3,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      sevenDays[index],
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      sevenDaysOfWeek[index],
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              height: 10,
              color: NyamColors.customSkyBlue,
            ),
            RestaurantPicker(
              seoulRestaurantName: HomeScreen.seoulRestaurantName,
              ansungRestaurantName: HomeScreen.ansungRestaurantName,
            ),
            Expanded(
              child: FutureBuilder(
                future: meals,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return PageView.builder(
                    controller: HomeScreen.pageController,
                    onPageChanged: (value) {
                      setState(() {
                        if (HomeScreen.entryPoint == CampusType.seoul) {
                          HomeScreen.isSelectedRestaurant = [
                            false,
                            false,
                            false,
                            false,
                            false,
                          ];
                        } else {
                          HomeScreen.isSelectedRestaurant = [
                            false,
                            false,
                            false,
                          ];
                        }

                        HomeScreen.isSelectedRestaurant[value] = true;
                        HomeScreen.autoScrollController.animateTo(
                          value * 30,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      });
                    },
                    itemCount: HomeScreen.entryPoint == CampusType.seoul
                        ? HomeScreen.seoulRestaurantName.length
                        : HomeScreen.ansungRestaurantName.length,
                    itemBuilder: (context, index) {
                      var restaurantName =
                          HomeScreen.entryPoint == CampusType.seoul
                              ? HomeScreen.seoulRestaurantName[index]
                              : HomeScreen.ansungRestaurantName[index];
                      return MealsOfRestaurant(
                        restaurantName: restaurantName,
                        mealsForDay: snapshot.data!,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealsOfRestaurant extends StatefulWidget {
  MealsOfRestaurant({
    super.key,
    required this.mealsForDay,
    required this.restaurantName,
  });

  MealsForDay mealsForDay;

  String restaurantName;

  @override
  State<MealsOfRestaurant> createState() => _MealsOfRestaurantState();
}

class _MealsOfRestaurantState extends State<MealsOfRestaurant> {
  @override
  void initState() {
    super.initState();
    setRestaurantName(widget.restaurantName);
    setMealsByTime();
    checkIsTodayMeals();
    checkIsBurgerOrRamen();
  }

  MealsForDay mealsOfRestaurant = [];
  MealsForDay breakfast = [];
  MealsForDay lunch = [];
  MealsForDay dinner = [];
  bool isTodayMeals = true;
  bool isBurgerOrRamen = false;
  String restaurantDetailName = "";

  void checkIsTodayMeals() {
    if (widget.mealsForDay.isNotEmpty) {
      isTodayMeals =
          DateFormat('yyyy-MM-dd').format(widget.mealsForDay[0].date) ==
                  DateFormat('yyyy-MM-dd').format(DateTime.now())
              ? true
              : false;
    }
  }

  void checkIsBurgerOrRamen() {
    if (widget.restaurantName == "카우버거" || widget.restaurantName == "라면") {
      isBurgerOrRamen = true;
    }
  }

  void setRestaurantName(String restaurantName) {
    RestaurantType restaurantType;
    switch (restaurantName) {
      case "참슬기":
        restaurantType = RestaurantType.chamsulgi;
        restaurantDetailName = "경영경제관 310관 B4층";
        break;
      case "생활관A":
        restaurantType = RestaurantType.domitoryA;
        restaurantDetailName = "블루미르홀 308관";
        break;
      case "생활관B":
        restaurantType = RestaurantType.domitoryB;
        restaurantDetailName = "블루미르홀 309관";
        break;
      case "학생식당":
        restaurantType = RestaurantType.student;
        restaurantDetailName = "법학관 303관 B1층";
        break;
      case "교직원":
        restaurantType = RestaurantType.staff;
        restaurantDetailName = "법학관 303관 B1층";
        break;
      case "카우이츠":
        restaurantType = RestaurantType.cauEats;
        restaurantDetailName = "707관";
        break;
      case "카우버거":
        restaurantType = RestaurantType.cauBurger;
        restaurantDetailName = "707관";
        break;
      case "라면":
        restaurantType = RestaurantType.ramen;
        restaurantDetailName = "707관";
        break;
      default:
        restaurantType = RestaurantType.chamsulgi;
        break;
    }

    mealsOfRestaurant = widget.mealsForDay.where((element) {
      return element.restaurantType == restaurantType;
    }).toList();
  }

  void setMealsByTime() {
    breakfast = mealsOfRestaurant.where((element) {
      return element.mealTime == MealTime.breakfast;
    }).toList();
    lunch = mealsOfRestaurant.where((element) {
      return element.mealTime == MealTime.lunch;
    }).toList();
    dinner = mealsOfRestaurant.where((element) {
      return element.mealTime == MealTime.dinner;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 210,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
            bottom: 20,
            top: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  restaurantDetailName,
                  style: const TextStyle(
                    color: NyamColors.grey50,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: isBurgerOrRamen ? 1 : 3,
                  itemBuilder: (context, index) {
                    var meals = [breakfast, lunch, dinner];
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 7,
                        bottom: 7,
                      ),
                      child: Menu(
                        isTodayMeals: isTodayMeals,
                        timeIndex: index,
                        mealsForDay: meals[index],
                        restaurantName: widget.restaurantName,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
