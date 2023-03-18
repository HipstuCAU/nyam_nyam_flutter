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
    setIcon();
    setTitle();
  }

  void checkIsBurgerOrRamen() {
    if (widget.restaurantName == "카우버거" || widget.restaurantName == "라면") {
      isBurgerOrRamen = true;
    }
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
      isOpenedToSee = false;
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
                  : Colors.black,
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
                    if (!isBurgerOrRamen) icon,
                    Padding(
                      padding: isBurgerOrRamen
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(left: 10),
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
                        if (openStatus != OpenStatusType.notRunning) {
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
                  right: 20,
                  bottom: 10,
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
                      var menu = widget.mealsForDay[index].menu;
                      if (widget.restaurantName == "라면") {
                        menu = menu.sublist(1);
                      } else if (widget.restaurantName == "카우버거") {
                        menu = menu[0].split("/").sublist(1);
                        crossCount = 1;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
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
                                      ),
                                    ),
                                    Text(
                                      widget.mealsForDay[index].price,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.mealsForDay[0].restaurantType ==
                                            RestaurantType.cauBurger
                                        ? ""
                                        : widget.mealsForDay[index].price,
                                    style: TextStyle(
                                      fontSize: widget.mealsForDay[0]
                                                  .restaurantType ==
                                              RestaurantType.cauBurger
                                          ? 0
                                          : 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                    ),
                                    child: GridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossCount,
                                        childAspectRatio: 5,
                                      ),
                                      itemCount: menu.length,
                                      itemBuilder: (context, index) {
                                        return SizedBox(
                                          child: Text(
                                            menu[index],
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
