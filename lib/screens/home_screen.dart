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
  List<String> restaurantName = [];

  @override
  void initState() {
    super.initState();
    get7daysFromToday();
    getRestaurantsName(SeoulRestaurantType.values);
  }

  List<String> getRestaurantsName(List<SeoulRestaurantType> restaurantTypes) {
    print(restaurantTypes.toString());
    return restaurantName;
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
      body: Column(
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
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: entryPoint == CampusType.Seoul
                  ? SeoulRestaurantType.values.length
                  : AnsungRestaurantType.values.length,
              itemBuilder: (context, index) {
                return Text(
                  entryPoint == CampusType.Seoul
                      ? SeoulRestaurantType.values[index]
                          .toString()
                          .split('.')[1]
                      : AnsungRestaurantType.values[index].toString(),
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
