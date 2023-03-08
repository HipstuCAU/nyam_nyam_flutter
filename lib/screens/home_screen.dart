import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'dart:ui' as ui;
import 'package:intl/date_symbol_data_local.dart';
import 'package:nyam_nyam_flutter/widgets/menu_widget.dart';
import 'package:nyam_nyam_flutter/widgets/restaurantPicker_widget.dart';
import 'package:nyam_nyam_flutter/widgets/sevenDatePicker_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var sevenDays = [];
  var sevenDaysOfWeek = [];
  Map<String, String> sevenDates = {};
  List<bool> isSelectedDate = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  List<String> seoulRestaurantName = ['참슬기', '생활관A', '생활관B', '학생식당', '교직원'];

  List<String> ansungRestaurantName = ['카우이츠', '카우버거', '라면'];

  var currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    get7daysFromToday();
  }

  Map<String, String> get7daysFromToday() {
    var today = DateTime.now().add(const Duration(hours: 19));
    for (int i = 0; i < 7; i++) {
      initializeDateFormatting();
      DateTime date = today.subtract(Duration(days: -i));
      sevenDays.add(int.parse(DateFormat('dd').format(date)).toString());
      sevenDaysOfWeek.add(DateFormat.E('ko_KR').format(date));
      sevenDates[sevenDaysOfWeek[i]] = sevenDays[i];
    }

    return sevenDates;
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
                    onPressed: () {},
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
            SevenDatePicker(
              isSelectedDate: isSelectedDate,
              sevenDays: sevenDays,
              sevenDaysOfWeek: sevenDaysOfWeek,
            ),
            Container(
              height: 10,
              color: NyamColors.customSkyBlue,
            ),
            RestaurantPicker(
              seoulRestaurantName: seoulRestaurantName,
              ansungRestaurantName: ansungRestaurantName,
            ),
            Expanded(
              child: PageView.builder(
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
                    ? seoulRestaurantName.length
                    : ansungRestaurantName.length,
                itemBuilder: (context, index) {
                  return MealsOfRestaurant(
                    restaurantName: seoulRestaurantName[index],
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

class MealsOfRestaurant extends StatelessWidget {
  MealsOfRestaurant({
    super.key,
    required this.restaurantName,
  });

  String restaurantName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 210,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  bottom: 10,
                ),
                child: Text(
                  restaurantName,
                  style: const TextStyle(
                    color: NyamColors.grey50,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Menu(
                mealTime: "조식",
              ),
              const SizedBox(
                height: 14,
              ),
              Menu(
                mealTime: "중식",
              ),
              const SizedBox(
                height: 14,
              ),
              Menu(
                mealTime: "석식",
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
