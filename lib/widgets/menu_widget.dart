import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';

class Menu extends StatefulWidget {
  const Menu({
    super.key,
    required this.mealsForDay,
    required this.restaurantName,
    required this.timeIndex,
    required this.isTodayMeals,
  });

  final MealsForDay mealsForDay;
  final String restaurantName;
  final int timeIndex;
  final bool isTodayMeals;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Text mealsTitle = const Text(
    "",
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: NyamColors.grey700,
    ),
  );

  MealsForDay meals = [];
  bool hasOperatingHours = false;
  bool isOpenedToSee = true;
  bool isBurgerOrRamen = false;
  int openTimeint = 0;
  int closeTimeint = 0;
  int now = 0;
  String openTimeString = "";
  String closeTimeString = "";
  OpenStatusType openStatus = OpenStatusType.notRunning;

  @override
  void initState() {
    super.initState();
    _updateMeals();
  }

  @override
  void didUpdateWidget(covariant Menu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mealsForDay != widget.mealsForDay ||
        oldWidget.restaurantName != widget.restaurantName ||
        oldWidget.isTodayMeals != widget.isTodayMeals ||
        oldWidget.timeIndex != widget.timeIndex) {
      _updateMeals();
    }
  }

  void _updateMeals() {
    meals = List.of(widget.mealsForDay)
      ..sort((a, b) => b.menu.length.compareTo(a.menu.length));
    isBurgerOrRamen =
        widget.restaurantName == '카우버거' || widget.restaurantName == '라면';
    hasOperatingHours = false;
    openTimeString = '';
    closeTimeString = '';
    isOpenedToSee = true;
    setOpenTime();
    setStatus();
    if (isBurgerOrRamen) {
      final MealsForDay uniqueMeals = [];
      for (final meal in meals) {
        if (!uniqueMeals.any(
          (item) =>
              item.price == meal.price && listEquals(item.menu, meal.menu),
        )) {
          uniqueMeals.add(meal);
        }
      }
      meals = uniqueMeals;
    }
    setTitle();
  }

  void setOpenTime() {
    final ranges = meals.where(
      (meal) =>
          meal.openTime.length >= 2 &&
          meal.openType != OpenType.closed &&
          !(meal.openType == OpenType.closeOnWeekends &&
              meal.date.weekday >= DateTime.saturday),
    );
    if (ranges.isEmpty) return;
    int minutes(DateTime time) => time.hour * 60 + time.minute;
    final opening = ranges
        .map((meal) => minutes(meal.openTime[0]))
        .reduce((a, b) => a < b ? a : b);
    final closing = ranges
        .map((meal) => minutes(meal.openTime[1]))
        .reduce((a, b) => a > b ? a : b);
    String formatTime(int time) =>
        '${(time ~/ 60).toString().padLeft(2, '0')}:${(time % 60).toString().padLeft(2, '0')}';
    openTimeString = formatTime(opening);
    closeTimeString = formatTime(closing);
    openTimeint = opening ~/ 60 * 100 + opening % 60;
    closeTimeint = closing ~/ 60 * 100 + closing % 60;
    hasOperatingHours = true;
    final currentTime = DateTime.now();
    now = currentTime.hour * 100 + currentTime.minute;
  }

  void setStatus() {
    if (meals.isEmpty ||
        meals.every(
          (meal) =>
              meal.openType == OpenType.closed ||
              (meal.openType == OpenType.closeOnWeekends &&
                  meal.date.weekday >= DateTime.saturday),
        )) {
      openStatus = OpenStatusType.notRunning;
      isOpenedToSee = false;
    } else if (!widget.isTodayMeals ||
        !hasOperatingHours ||
        now < openTimeint) {
      openStatus = OpenStatusType.preparing;
    } else if (now < closeTimeint) {
      openStatus = OpenStatusType.running;
    } else {
      openStatus = OpenStatusType.closed;
      isOpenedToSee = false;
    }
  }

  // deprecated
  // void setIcon() {
  //   switch (widget.timeIndex) {
  //     case 0:
  //       icon = Icon(
  //         Icons.sunny_snowing,
  //         size: 20,
  //         color: openStatus == OpenStatusType.notRunning ||
  //                 openStatus == OpenStatusType.closed
  //             ? NyamColors.grey50
  //             : Colors.black,
  //       );
  //       break;
  //     case 1:
  //       icon = Icon(
  //         Icons.sunny,
  //         size: 20,
  //         color: openStatus == OpenStatusType.notRunning ||
  //                 openStatus == OpenStatusType.closed
  //             ? NyamColors.grey50
  //             : Colors.black,
  //       );
  //       break;
  //     case 2:
  //       icon = Icon(
  //         Icons.nights_stay,
  //         size: 20,
  //         color: openStatus == OpenStatusType.notRunning ||
  //                 openStatus == OpenStatusType.closed
  //             ? NyamColors.grey50
  //             : Colors.black,
  //       );
  //       break;
  //     default:
  //       icon = Icon(
  //         Icons.nights_stay,
  //         size: 20,
  //         color: openStatus == OpenStatusType.notRunning ||
  //                 openStatus == OpenStatusType.closed
  //             ? NyamColors.grey50
  //             : Colors.black,
  //       );
  //       break;
  //   }
  // }

  void setTitle() {
    if (isBurgerOrRamen) {
      switch (widget.restaurantName) {
        case "카우버거":
          mealsTitle = Text(
            "카우버거",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  openStatus == OpenStatusType.notRunning ||
                      openStatus == OpenStatusType.closed
                  ? NyamColors.grey50
                  : NyamColors.grey700,
            ),
          );
          break;
        case "라면":
          mealsTitle = Text(
            "라면",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  openStatus == OpenStatusType.notRunning ||
                      openStatus == OpenStatusType.closed
                  ? NyamColors.grey50
                  : NyamColors.grey700,
            ),
          );
          break;
        default:
          mealsTitle = Text(
            "기타",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  openStatus == OpenStatusType.notRunning ||
                      openStatus == OpenStatusType.closed
                  ? NyamColors.grey50
                  : NyamColors.grey700,
            ),
          );
          break;
      }
    } else {
      switch (widget.timeIndex) {
        case 0:
          mealsTitle = Text(
            "조식",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: openStatus == OpenStatusType.notRunning
                  ? NyamColors.grey50
                  : NyamColors.grey700,
            ),
          );
          break;
        case 1:
          mealsTitle = Text(
            "중식",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: openStatus == OpenStatusType.notRunning
                  ? NyamColors.grey50
                  : NyamColors.grey700,
            ),
          );
          break;
        case 2:
          mealsTitle = Text(
            "석식",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: openStatus == OpenStatusType.notRunning
                  ? NyamColors.grey50
                  : NyamColors.grey700,
            ),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (openStatus != OpenStatusType.notRunning) {
            isOpenedToSee = !isOpenedToSee;
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 10,
            top: 16,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  mealsTitle,
                  Row(
                    children: [
                      OpenState(
                        openTimeString: openTimeString,
                        closeTimeString: closeTimeString,
                        openStatusType: openStatus,
                        mealsForDay: meals,
                        hasOperatingHours: hasOperatingHours,
                      ),
                      Icon(
                        isOpenedToSee
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: NyamColors.grey400,
                      ),
                    ],
                  ),
                ],
              ),
              if (isOpenedToSee)
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20,
                    bottom: 10,
                    top: 10,
                  ),
                  child: MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(
                        height: 0.5,
                        color: NyamColors.customGrey.withValues(alpha: 0.5),
                      ),
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        var crossCount = 2;
                        var menu = meals[index].menu;

                        // 라면 메뉴 변경됨
                        // if (widget.restaurantName == "라면") {
                        //   menu = menu;
                        // } else

                        if (widget.restaurantName == "카우버거" ||
                            widget.restaurantName == "생활관B") {
                          // menu = [(menu[0])];
                          crossCount = 1;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.restaurantName == "학생식당" &&
                                  menu.length == 1)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        menu[0],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: NyamColors.grey600,
                                        ),
                                      ),
                                      Text(
                                        meals[index].price,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: NyamColors.grey600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (widget.restaurantName == "카우버거")
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    children: [
                                      Text(
                                        menu.isEmpty ? '' : menu[0],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: NyamColors.grey600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.restaurantName != "카우버거")
                                      Text(
                                        meals[index].price,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: NyamColors.grey600,
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossCount,
                                              childAspectRatio: crossCount == 1
                                                  ? 9
                                                  : 4,
                                            ),
                                        itemCount: menu.length,
                                        itemBuilder: (context, index) {
                                          return SizedBox(
                                            child: Text(
                                              menu[index],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: NyamColors.grey700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OpenState extends StatelessWidget {
  const OpenState({
    super.key,
    required this.mealsForDay,
    required this.openStatusType,
    required this.openTimeString,
    required this.closeTimeString,
    this.hasOperatingHours = true,
  });

  final MealsForDay mealsForDay;
  final OpenStatusType openStatusType;
  final String openTimeString;
  final String closeTimeString;
  final bool hasOperatingHours;

  @override
  Widget build(BuildContext context) {
    final titleColor = switch (openStatusType) {
      OpenStatusType.preparing => NyamColors.customYellow,
      OpenStatusType.running => NyamColors.customBlue,
      OpenStatusType.closed => NyamColors.customRed,
      OpenStatusType.notRunning => NyamColors.customGrey,
    };
    final title =
        openStatusType != OpenStatusType.notRunning && !hasOperatingHours
        ? '영업시간 정보 없음'
        : switch (openStatusType) {
            OpenStatusType.preparing => '준비중 $openTimeString~$closeTimeString',
            OpenStatusType.running => '운영중 $openTimeString~$closeTimeString',
            OpenStatusType.closed => '운영종료',
            OpenStatusType.notRunning => '미운영',
          };
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
      ),
    );
  }
}
