import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nyam_nyam_flutter/widgets/homeScreenTopBar_widget.dart';
import 'package:nyam_nyam_flutter/widgets/restaurantPicker_widget.dart';
import 'package:nyam_nyam_flutter/widgets/sevenDatePicker_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CampusType entryPoint = CampusType.Seoul;

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
  List<String> seoulRestaurantName = ['참슬기', '생활관A', '생활관B', '학생식당', '교직원식당'];
  List<String> ansungRestaurantName = ['카우이츠', '카우', '라면'];

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
            const Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 10,
                bottom: 4,
              ),
              child: HomeScreenTopBar(),
            ),
            Container(
              height: 10,
              color: NyamColors.customSkyBlue,
            ),
            SevenDatePicker(
                isSelectedDate: isSelectedDate,
                sevenDays: sevenDays,
                sevenDaysOfWeek: sevenDaysOfWeek),
            Container(
              height: 10,
              color: NyamColors.customSkyBlue,
            ),
            RestaurantPicker(
                entryPoint: entryPoint,
                isSelectedRestaurant: isSelectedRestaurant,
                seoulRestaurantName: seoulRestaurantName,
                ansungRestaurantName: ansungRestaurantName),
          ],
        ),
      ),
    );
  }
}
