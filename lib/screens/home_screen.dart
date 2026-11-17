import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';

import 'dart:ui' as ui;

import 'package:nyam_nyam_flutter/models/meal.dart';
import 'package:nyam_nyam_flutter/screens/setting_screen.dart';
import 'package:nyam_nyam_flutter/services/api_service.dart';
import 'package:nyam_nyam_flutter/widgets/menu_widget.dart';
import 'package:nyam_nyam_flutter/widgets/restaurantPicker_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.loadMeals});

  final Future<List<MealsForWeek>> Function()? loadMeals;

  static CampusType entryPoint = CampusType.seoul;
  static List<bool> isSelectedRestaurant = List.generate(
    defaultSeoulRestaurants.length,
    (index) => index == 0,
  );
  static PageController pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.9,
  );
  static AutoScrollController autoScrollController = AutoScrollController();
  static const defaultSeoulRestaurants = [
    '참슬기',
    '생활관A',
    '생활관B',
    '학생식당',
    '교직원',
    'University Club',
  ];
  static const defaultAnsungRestaurants = ['카우이츠', '카우버거', '라면'];
  static List<String> seoulRestaurantName = [...defaultSeoulRestaurants];
  static List<String> ansungRestaurantName = [...defaultAnsungRestaurants];

  static Future<void> restoreRestaurantOrders() async {
    final seoul = preferences.getStringList('sortedSeoulRestaurants');
    final ansung = preferences.getStringList('sortedAnsungRestaurants');
    seoulRestaurantName = {...?seoul, ...defaultSeoulRestaurants}.toList();
    ansungRestaurantName = {...?ansung, ...defaultAnsungRestaurants}.toList();
    if (!listEquals(seoul, seoulRestaurantName)) {
      await preferences.setStringList(
        'sortedSeoulRestaurants',
        seoulRestaurantName,
      );
    }
    if (!listEquals(ansung, ansungRestaurantName)) {
      await preferences.setStringList(
        'sortedAnsungRestaurants',
        ansungRestaurantName,
      );
    }
  }

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
  final List<String> sevenDays = [];
  final List<String> sevenDaysOfWeek = [];
  final List<String> sevenDateTime = [];
  late final PageController _pageController;
  late final AutoScrollController _autoScrollController;
  late final Future<void> _preferencesReady;
  late Future<List<MealsForWeek>> allMeals;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _autoScrollController = AutoScrollController();
    HomeScreen.pageController = _pageController;
    HomeScreen.autoScrollController = _autoScrollController;
    HomeScreen.isSelectedDate = List.generate(7, (index) => index == 0);
    get7daysFromToday();
    _preferencesReady = initPreferences();
    allMeals = _loadMeals();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollController.dispose();
    super.dispose();
  }

  Future<void> initPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    HomeScreen.preferences = preferences;
    final favoriteCampus = preferences.getString('favoriteCampus');
    HomeScreen.entryPoint = favoriteCampus == '안성'
        ? CampusType.ansung
        : CampusType.seoul;
    if (favoriteCampus == null) {
      await preferences.setString('favoriteCampus', '서울');
    }
    await HomeScreen.restoreRestaurantOrders();
    if (!mounted) return;
    resetRestaurantPicker();
  }

  Future<List<MealsForWeek>> _loadMeals() async {
    await _preferencesReady;
    if (!mounted) return [];
    if (widget.loadMeals != null) return widget.loadMeals!();
    final service = ApiService();
    final data = await service.getJsonFromFirebase();
    return service.getMeals(data);
  }

  void get7daysFromToday() {
    final today = DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    for (var i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      sevenDateTime.add(DateFormat('yyyy-MM-dd').format(date));
      sevenDays.add(date.day.toString());
      sevenDaysOfWeek.add(weekdays[date.weekday - 1]);
    }
  }

  void showToast() {
    Fluttertoast.showToast(
      msg: "😂 아직 식단이 업데이트 되지 않았어요",
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFF4E5968).withValues(alpha: 0.98),
      fontSize: 16,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void resetRestaurantPicker() {
    final count = HomeScreen.entryPoint == CampusType.seoul
        ? HomeScreen.seoulRestaurantName.length
        : HomeScreen.ansungRestaurantName.length;
    HomeScreen.isSelectedRestaurant = List.generate(
      count,
      (index) => index == 0,
    );
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _selectCampus(CampusType campus) {
    Navigator.pop(context);
    setState(() {
      HomeScreen.entryPoint = campus;
      HomeScreen.isSelectedDate = List.generate(7, (index) => index == 0);
      resetRestaurantPicker();
    });
  }

  void _retry() {
    setState(() {
      allMeals = _loadMeals();
    });
  }

  Widget _loadMessage(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          TextButton(onPressed: _retry, child: const Text('다시 시도')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: NyamColors.gradientBG),
        child: FutureBuilder(
          future: allMeals,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: NyamColors.cauBlue),
              );
            }

            if (snapshot.hasError) {
              return _loadMessage('식단을 불러오지 못했어요.');
            }
            final allCampusMeals = snapshot.data ?? [];
            if (allCampusMeals.isEmpty) {
              return _loadMessage('아직 등록된 식단이 없어요.');
            }

            final campusIndex = HomeScreen.entryPoint == CampusType.seoul
                ? 0
                : 1;
            final MealsForWeek meals = campusIndex < allCampusMeals.length
                ? allCampusMeals[campusIndex]
                : {};
            final isUploadedDates = List.generate(
              7,
              (index) => meals[sevenDateTime[index]]?.isNotEmpty ?? false,
            );
            final selectedDate = HomeScreen.isSelectedDate.indexOf(true);
            final mealsByDate =
                meals[sevenDateTime[selectedDate]] ?? <MealModel>[];

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
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
                                            _selectCampus(CampusType.seoul);
                                          },
                                          child: const Text(
                                            "서울캠퍼스",
                                            style: TextStyle(
                                              color: NyamColors.cauBlue,
                                            ),
                                          ),
                                        ),
                                        CupertinoActionSheetAction(
                                          onPressed: () {
                                            _selectCampus(CampusType.ansung);
                                          },
                                          child: const Text(
                                            "안성캠퍼스",
                                            style: TextStyle(
                                              color: NyamColors.cauBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        isDefaultAction: true,
                                        onPressed: () {
                                          Navigator.pop(context, 'Cancel');
                                        },
                                        child: const Text(
                                          "취소",
                                          style: TextStyle(
                                            color: NyamColors.cauBlue,
                                          ),
                                        ),
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
                                await Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          var begin = const Offset(1, 0);
                                          var end = Offset.zero;
                                          var curve = Curves.ease;
                                          var tween = Tween(
                                            begin: begin,
                                            end: end,
                                          ).chain(CurveTween(curve: curve));
                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                    pageBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                    ) => SettingScreen(),
                                  ),
                                );
                                if (!mounted) return;
                                setState(resetRestaurantPicker);
                              },
                              icon: const Icon(Icons.settings),
                              color: NyamColors.customGrey,
                              iconSize: 25,
                            ),
                          ],
                        ),
                      ),
                      Container(height: 10, color: NyamColors.customSkyBlue),
                      Container(
                        color: NyamColors.customSkyBlue,
                        height: 52,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            Color textColor = NyamColors.grey50;
                            if (isUploadedDates[index] == true) {
                              if (HomeScreen.isSelectedDate[index]) {
                                textColor = Colors.white;
                              } else {
                                textColor = NyamColors.customBlack;
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                if (!isUploadedDates[index]) {
                                  showToast();
                                  return;
                                }
                                if (HomeScreen.isSelectedDate[index]) return;
                                setState(() {
                                  HomeScreen.isSelectedDate = List.generate(
                                    7,
                                    (day) => day == index,
                                  );
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width / 30,
                                ),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 13,
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
                                      padding: const EdgeInsets.only(top: 3),
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
                                              fontSize: 14,
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
                        ),
                      ),
                      Container(height: 10, color: NyamColors.customSkyBlue),
                      RestaurantPicker(
                        seoulRestaurantName: HomeScreen.seoulRestaurantName,
                        ansungRestaurantName: HomeScreen.ansungRestaurantName,
                      ),
                    ],
                  ),
                ),
              ],
              body: mealsByDate.isEmpty
                  ? const Center(child: Text('아직 등록된 식단이 없어요.'))
                  : PageView.builder(
                      controller: _pageController,
                      onPageChanged: (value) {
                        setState(() {
                          final count =
                              HomeScreen.entryPoint == CampusType.seoul
                              ? HomeScreen.seoulRestaurantName.length
                              : HomeScreen.ansungRestaurantName.length;
                          HomeScreen.isSelectedRestaurant = List.filled(
                            count,
                            false,
                          );
                          HomeScreen.isSelectedRestaurant[value] = true;
                          if (_autoScrollController.hasClients) {
                            _autoScrollController.animateTo(
                              (value * 30.0).clamp(
                                0.0,
                                _autoScrollController.position.maxScrollExtent,
                              ),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
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
                          mealsForDay: mealsByDate,
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}

class MealsOfRestaurant extends StatefulWidget {
  const MealsOfRestaurant({
    super.key,
    required this.mealsForDay,
    required this.restaurantName,
  });

  final MealsForDay mealsForDay;
  final String restaurantName;

  @override
  State<MealsOfRestaurant> createState() => _MealsOfRestaurantState();
}

class _MealsOfRestaurantState extends State<MealsOfRestaurant> {
  @override
  void initState() {
    super.initState();
    _updateMeals();
  }

  @override
  void didUpdateWidget(covariant MealsOfRestaurant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mealsForDay != widget.mealsForDay ||
        oldWidget.restaurantName != widget.restaurantName) {
      _updateMeals();
    }
  }

  void _updateMeals() {
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
    isBurgerOrRamen =
        widget.restaurantName == '카우버거' || widget.restaurantName == '라면';
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
      case 'University Club':
        restaurantType = RestaurantType.universityClub;
        restaurantDetailName = '102관 11층';
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
    return SingleChildScrollView(
      primary: true,
      child: PrimaryScrollController.none(
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
                padding: const EdgeInsets.only(left: 10),
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
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Menu(
                        isTodayMeals: isTodayMeals,
                        timeIndex: index,
                        mealsForDay: isBurgerOrRamen
                            ? mealsOfRestaurant
                            : meals[index],
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
