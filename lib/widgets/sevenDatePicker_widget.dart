import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/screens/home_screen.dart';

class SevenDatePicker extends StatefulWidget {
  const SevenDatePicker({
    super.key,
    required this.sevenDays,
    required this.sevenDaysOfWeek,
  });

  final List sevenDays;
  final List sevenDaysOfWeek;

  @override
  State<SevenDatePicker> createState() => _SevenDatePickerState();
}

class _SevenDatePickerState extends State<SevenDatePicker> {
  void touchUpToInsideToSelectDate(int index) {
    setState(() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NyamColors.customSkyBlue,
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              touchUpToInsideToSelectDate(index);
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
                          widget.sevenDays[index],
                          style: TextStyle(
                            color: HomeScreen.isSelectedDate[index]
                                ? Colors.white
                                : NyamColors.customBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.sevenDaysOfWeek[index],
                          style: TextStyle(
                            color: HomeScreen.isSelectedDate[index]
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
              ),
            ),
          );
        },
      ),
    );
  }
}
