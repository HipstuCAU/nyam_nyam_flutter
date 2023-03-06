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
    var today = DateTime.now();

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
                top: 20,
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
          ],
        ),
      ),
    );
  }
}
