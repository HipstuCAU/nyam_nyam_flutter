import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'dart:ui' as ui;
import 'package:intl/date_symbol_data_local.dart';
import 'package:nyam_nyam_flutter/widgets/restaurantPicker_widget.dart';
import 'package:nyam_nyam_flutter/widgets/sevenDatePicker_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static CampusType entryPoint = CampusType.seoul;
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
  List<bool> isSelectedRestaurant = [
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

  @override
  void initState() {
    super.initState();
    get7daysFromToday();
  }

  Map<String, String> get7daysFromToday() {
    var today = DateTime.now().add(const Duration(hours: 19));
    print(today);
    for (int i = 0; i < 7; i++) {
      initializeDateFormatting();
      DateTime date = today.subtract(Duration(days: -i));
      sevenDays.add(int.parse(DateFormat('dd').format(date)).toString());
      sevenDaysOfWeek.add(DateFormat.E('ko_KR').format(date));
      sevenDates[sevenDaysOfWeek[i]] = sevenDays[i];
    }

    print(sevenDaysOfWeek);

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
              isSelectedRestaurant: isSelectedRestaurant,
              seoulRestaurantName: seoulRestaurantName,
              ansungRestaurantName: ansungRestaurantName,
            ),
            Expanded(
              child: PageView.builder(
                controller: PageController(initialPage: 0),
                itemCount: HomeScreen.entryPoint == CampusType.seoul
                    ? seoulRestaurantName.length
                    : ansungRestaurantName.length,
                itemBuilder: (context, index) {
                  return const MealsOfRestaurant();
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
  const MealsOfRestaurant({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 210,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  bottom: 10,
                ),
                child: Text(
                  "경영경제관 310관 B4층",
                  style: TextStyle(
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

class Menu extends StatefulWidget {
  Menu({
    super.key,
    required this.mealTime,
  });

  String mealTime;
  DateTime now = DateTime.now();

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late Icon icon;

  bool isOpenedToSee = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sunny_snowing,
                      size: 20,
                    ),
                    Text(
                      "  ${widget.mealTime}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: OpenState(),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        isOpenedToSee = !isOpenedToSee;
                      });
                    },
                    icon: Icon(
                      isOpenedToSee
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                    ))
              ],
            ),
            if (isOpenedToSee)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 6,
                      bottom: 0,
                    ),
                    child: Text(
                      "3200원",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 4,
                      ),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return const SizedBox(
                          child: Text(
                            "된장찌개",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

class OpenState extends StatelessWidget {
  const OpenState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NyamColors.customYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        child: Text(
          "준비중",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: NyamColors.customYellow,
          ),
        ),
      ),
    );
  }
}
