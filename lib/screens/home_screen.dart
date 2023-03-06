import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
                      ? SeoulRestaurantType.values[index].toString()
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

class SevenDatePicker extends StatelessWidget {
  const SevenDatePicker({
    super.key,
    required this.isSelectedDate,
    required this.sevenDays,
    required this.sevenDaysOfWeek,
  });

  final List<bool> isSelectedDate;
  final List sevenDays;
  final List sevenDaysOfWeek;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NyamColors.customSkyBlue,
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 28),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 14,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelectedDate[index]
                      ? NyamColors.cauBlue
                      : NyamColors.customSkyBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    Text(
                      sevenDays[index],
                      style: TextStyle(
                        color: isSelectedDate[index]
                            ? Colors.white
                            : NyamColors.customBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      sevenDaysOfWeek[index],
                      style: TextStyle(
                        color: isSelectedDate[index]
                            ? Colors.white
                            : NyamColors.customBlack,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HomeScreenTopBar extends StatelessWidget {
  const HomeScreenTopBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: (() {}),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: NyamColors.customGrey,
            size: 35,
          ),
          label: const Text(
            "서울캠퍼스",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
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
    );
  }
}
