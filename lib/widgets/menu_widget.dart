import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';

class Menu extends StatefulWidget {
  Menu({
    super.key,
    required this.mealsForDay,
    required this.restaurantName,
    required this.timeIndex,
    required this.isTodayMeals,
  });

  MealsForDay mealsForDay;
  String restaurantName;
  DateTime now = DateTime.now();
  int timeIndex;
  bool isTodayMeals;

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
    checkIsBurgerOrRamen();
    setOpenTime();
    setStatus();
    setTitle();
    sortStudentRestaurantMenu();
  }

  void sortStudentRestaurantMenu() {
    if (widget.restaurantName == "학생식당") {
      if (widget.mealsForDay.isNotEmpty) {
        var setmenu = widget.mealsForDay
            .where((element) => element.menu.length != 1)
            .toList();
        if (setmenu != []) {
          widget.mealsForDay.last = widget.mealsForDay.first;
          widget.mealsForDay.first = setmenu.first;
        }
      }
    }
  }

  void checkIsBurgerOrRamen() {
    if (widget.restaurantName == "카우버거" || widget.restaurantName == "라면") {
      isBurgerOrRamen = true;
    }
  }

  void setOpenTime() {
    if (widget.mealsForDay.isNotEmpty) {
      if (widget.restaurantName == "카우버거") {
        openTimeString = "09:30";
        closeTimeString = "18:30";
      } else if (widget.restaurantName == "라면") {
        openTimeString = "06:00";
        closeTimeString = "23:00";
      } else {
        openTimeString =
            widget.mealsForDay[0].openTime[0].toString().substring(11, 16);
        closeTimeString =
            widget.mealsForDay[0].openTime[1].toString().substring(11, 16);
      }
      openTimeint = int.parse(openTimeString.replaceAll(":", ""));
      closeTimeint = int.parse(closeTimeString.replaceAll(":", ""));
    }

    now = int.parse(
        DateTime.now().toString().substring(11, 16).replaceAll(":", ""));
  }

  void setStatus() {
    setState(() {});
    if (widget.mealsForDay.isNotEmpty) {
      if (widget.isTodayMeals) {
        if (now < openTimeint) {
          openStatus = OpenStatusType.preparing;
        } else if (openTimeint < now && now < closeTimeint) {
          openStatus = OpenStatusType.running;
        } else {
          openStatus = OpenStatusType.closed;
          isOpenedToSee = false;
        }
      } else {
        openStatus = OpenStatusType.preparing;
      }
    } else {
      openStatus = OpenStatusType.notRunning;
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
              color: openStatus == OpenStatusType.notRunning ||
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
              color: openStatus == OpenStatusType.notRunning ||
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
              color: openStatus == OpenStatusType.notRunning ||
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
                        mealsForDay: widget.mealsForDay,
                      ),
                      Icon(
                        isOpenedToSee
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: NyamColors.grey400,
                      ),
                    ],
                  )
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
                        color: NyamColors.customGrey.withOpacity(0.5),
                      ),
                      itemCount: widget.mealsForDay.length,
                      itemBuilder: (context, index) {
                        var crossCount = 2;
                        widget.mealsForDay.sort(
                            (b, a) => a.menu.length.compareTo(b.menu.length));
                        var menu = widget.mealsForDay[index].menu;

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
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 5,
                          ),
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
                                        widget.mealsForDay[index].price,
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
                                        menu[0],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: NyamColors.grey600,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.restaurantName != "카우버거")
                                      Text(
                                        widget.mealsForDay[index].price,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: NyamColors.grey600,
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                      ),
                                      child: GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossCount,
                                          childAspectRatio:
                                              crossCount == 1 ? 9 : 4,
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
                                    )
                                  ],
                                )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class OpenState extends StatefulWidget {
  OpenState({
    super.key,
    required this.mealsForDay,
    required this.openStatusType,
    required this.openTimeString,
    required this.closeTimeString,
  });

  MealsForDay mealsForDay;
  OpenStatusType openStatusType;
  String openTimeString = "";
  String closeTimeString = "";

  @override
  State<OpenState> createState() => _OpenStateState();
}

class _OpenStateState extends State<OpenState> {
  Color backgrounColor = Colors.white;
  Color titleColor = NyamColors.customGrey;
  String title = "미운영";

  @override
  void initState() {
    super.initState();
    setColor();
    setTitle();
  }

  void setColor() {
    switch (widget.openStatusType) {
      case OpenStatusType.preparing:
        titleColor = NyamColors.customYellow;
        break;
      case OpenStatusType.running:
        titleColor = NyamColors.customBlue;
        break;
      case OpenStatusType.closed:
        titleColor = NyamColors.customRed;
        break;
      case OpenStatusType.notRunning:
        titleColor = NyamColors.customGrey;
        break;
    }
  }

  void setTitle() {
    switch (widget.openStatusType) {
      case OpenStatusType.preparing:
        title = "준비중 ${widget.openTimeString}~${widget.closeTimeString}";
        break;
      case OpenStatusType.running:
        title = "운영중 ${widget.openTimeString}~${widget.closeTimeString}";
        break;
      case OpenStatusType.closed:
        title = "운영종료";
        break;
      case OpenStatusType.notRunning:
        title = "미운영";
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgrounColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
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
