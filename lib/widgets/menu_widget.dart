import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';

class Menu extends StatefulWidget {
  Menu({
    super.key,
    required this.mealsForDay,
    required this.isBurgerOrRamen,
    required this.timeIndex,
    required this.isTodayMeals,
  });

  MealsForDay mealsForDay;
  bool isBurgerOrRamen;
  DateTime now = DateTime.now();
  int timeIndex;
  bool isTodayMeals;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Icon icon = const Icon(
    Icons.nights_stay,
    size: 20,
  );

  Text mealsTitle = const Text(
    "",
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );

  bool isOpenedToSee = true;
  int openTimeint = 0;
  int closeTimeint = 0;
  int now = 0;
  String openTimeString = "";
  String closeTimeString = "";
  OpenStatusType openStatus = OpenStatusType.notRunning;

  @override
  void initState() {
    super.initState();
    setOpenTime();
    setStatus();
    setIcon();
    setTitle();
  }

  void setOpenTime() {
    if (widget.mealsForDay.isNotEmpty) {
      openTimeString =
          widget.mealsForDay[0].openTime[0].toString().substring(11, 16);
      closeTimeString =
          widget.mealsForDay[0].openTime[1].toString().substring(11, 16);

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
    }
  }

  void setIcon() {
    switch (widget.timeIndex) {
      case 0:
        icon = Icon(
          Icons.sunny_snowing,
          size: 20,
          color: openStatus == OpenStatusType.notRunning ||
                  openStatus == OpenStatusType.closed
              ? NyamColors.grey50
              : Colors.black,
        );
        break;
      case 1:
        icon = Icon(
          Icons.sunny,
          size: 20,
          color: openStatus == OpenStatusType.notRunning ||
                  openStatus == OpenStatusType.closed
              ? NyamColors.grey50
              : Colors.black,
        );
        break;
      case 2:
        icon = Icon(
          Icons.nights_stay,
          size: 20,
          color: openStatus == OpenStatusType.notRunning ||
                  openStatus == OpenStatusType.closed
              ? NyamColors.grey50
              : Colors.black,
        );
        break;
      default:
        icon = Icon(
          Icons.nights_stay,
          size: 20,
          color: openStatus == OpenStatusType.notRunning ||
                  openStatus == OpenStatusType.closed
              ? NyamColors.grey50
              : Colors.black,
        );
        break;
    }
  }

  void setTitle() {
    if (widget.isBurgerOrRamen) {
      switch (widget.mealsForDay[0].restaurantType) {
        case RestaurantType.cauBurger:
          mealsTitle = Text(
            "카우버거",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: openStatus == OpenStatusType.notRunning ||
                      openStatus == OpenStatusType.closed
                  ? NyamColors.grey50
                  : Colors.black,
            ),
          );
          break;
        case RestaurantType.ramen:
          mealsTitle = Text(
            "라면",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: openStatus == OpenStatusType.notRunning ||
                      openStatus == OpenStatusType.closed
                  ? NyamColors.grey50
                  : Colors.black,
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
                  : Colors.black,
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
              color: openStatus == OpenStatusType.notRunning ||
                      openStatus == OpenStatusType.closed
                  ? NyamColors.grey50
                  : Colors.black,
            ),
          );
          break;
        case 1:
          mealsTitle = Text(
            "중식",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: openStatus == OpenStatusType.notRunning ||
                      openStatus == OpenStatusType.closed
                  ? NyamColors.grey50
                  : Colors.black,
            ),
          );
          break;
        case 2:
          mealsTitle = Text(
            "석식",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: openStatus == OpenStatusType.notRunning ||
                      openStatus == OpenStatusType.closed
                  ? NyamColors.grey50
                  : Colors.black,
            ),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
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
                    if (!widget.isBurgerOrRamen) icon,
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: mealsTitle,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: OpenState(
                        openTimeString: openTimeString,
                        closeTimeString: closeTimeString,
                        openStatusType: openStatus,
                        mealsForDay: widget.mealsForDay,
                      ),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        if (openStatus == OpenStatusType.notRunning) {
                          isOpenedToSee = !isOpenedToSee;
                        }
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
              Padding(
                padding: const EdgeInsets.only(
                  right: 20.0,
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
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mealsForDay[index].price,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
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
                                itemCount:
                                    widget.mealsForDay[index].menu.length,
                                itemBuilder: (context, index2) {
                                  return SizedBox(
                                    child: Text(
                                      widget.mealsForDay[index].menu[index2],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
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
  Color backgrounColor = NyamColors.grey50;
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
        backgrounColor = NyamColors.customYellow.withOpacity(0.2);
        titleColor = NyamColors.customYellow;
        break;
      case OpenStatusType.running:
        backgrounColor = NyamColors.customBlue.withOpacity(0.2);
        titleColor = NyamColors.customBlue;
        break;
      case OpenStatusType.closed:
        backgrounColor = NyamColors.customRed.withOpacity(0.2);
        titleColor = NyamColors.customRed;
        break;
      case OpenStatusType.notRunning:
        backgrounColor = NyamColors.grey50;
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
