import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';

class SevenDatePicker extends StatefulWidget {
  SevenDatePicker({
    super.key,
    required this.isSelectedDate,
    required this.sevenDays,
    required this.sevenDaysOfWeek,
  });

  List<bool> isSelectedDate;
  final List sevenDays;
  final List sevenDaysOfWeek;

  @override
  State<SevenDatePicker> createState() => _SevenDatePickerState();
}

class _SevenDatePickerState extends State<SevenDatePicker> {
  void touchUpToInsideToSelectDate(int index) {
    setState(() {
      if (widget.isSelectedDate[index] == true) {
        return;
      } else {
        widget.isSelectedDate = [
          false,
          false,
          false,
          false,
          false,
          false,
          false,
        ];
        widget.isSelectedDate[index] = true;
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
                    color: widget.isSelectedDate[index]
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
                            color: widget.isSelectedDate[index]
                                ? Colors.white
                                : NyamColors.customBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.sevenDaysOfWeek[index],
                          style: TextStyle(
                            color: widget.isSelectedDate[index]
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
