import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nyam_nyam_flutter/widgets/homeScreenTopBar_widget.dart';
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

class RestaurantPicker extends StatefulWidget {
  RestaurantPicker({
    super.key,
    required this.entryPoint,
    required this.isSelectedRestaurant,
    required this.seoulRestaurantName,
    required this.ansungRestaurantName,
  });

  final CampusType entryPoint;
  List<bool> isSelectedRestaurant;
  final List<String> seoulRestaurantName;
  final List<String> ansungRestaurantName;

  @override
  State<RestaurantPicker> createState() => _RestaurantPickerState();
}

class _RestaurantPickerState extends State<RestaurantPicker> {
  void touchUpToInsideToSelectRestaurant(int index) {
    setState(() {
      widget.isSelectedRestaurant = [
        false,
        false,
        false,
        false,
        false,
      ];
      widget.isSelectedRestaurant[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 14,
      ),
      child: SizedBox(
        height: 34,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.entryPoint == CampusType.Seoul
              ? SeoulRestaurantType.values.length
              : AnsungRestaurantType.values.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(
                left: 20,
                // right: 10,
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                      spreadRadius: 1,
                      color: Colors.black.withOpacity(0.1),
                    )
                  ],
                  color: widget.isSelectedRestaurant[index]
                      ? NyamColors.cauBlue
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: GestureDetector(
                  onTap: () {
                    touchUpToInsideToSelectRestaurant(index);
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                      widget.entryPoint == CampusType.Seoul
                          ? widget.seoulRestaurantName[index]
                          : widget.ansungRestaurantName[index],
                      style: TextStyle(
                        color: widget.isSelectedRestaurant[index]
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
