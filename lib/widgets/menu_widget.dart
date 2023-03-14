import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';

class Menu extends StatefulWidget {
  Menu({
    super.key,
    required this.mealsForDay,
    required this.isBurgerOrRamen,
    required this.timeIndex,
  });

  MealsForDay mealsForDay;
  bool isBurgerOrRamen;
  bool isNotRunning = false;
  DateTime now = DateTime.now();
  int timeIndex;

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

  @override
  void initState() {
    super.initState();
    checkIsRunning();
    setIcon();
    setTitle();
  }

  void checkIsRunning() {
    widget.isNotRunning = widget.mealsForDay.isEmpty ? true : false;
    print(widget.mealsForDay);
    print("check!");
  }

  void setIcon() {
    switch (widget.timeIndex) {
      case 0:
        icon = Icon(
          Icons.sunny_snowing,
          size: 20,
          color: widget.isNotRunning ? NyamColors.grey50 : Colors.black,
        );
        break;
      case 1:
        icon = Icon(
          Icons.sunny,
          size: 20,
          color: widget.isNotRunning ? NyamColors.grey50 : Colors.black,
        );
        break;
      case 2:
        icon = Icon(
          Icons.nights_stay,
          size: 20,
          color: widget.isNotRunning ? NyamColors.grey50 : Colors.black,
        );
        break;
      default:
        icon = Icon(
          Icons.nights_stay,
          size: 20,
          color: widget.isNotRunning ? NyamColors.grey50 : Colors.black,
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
              color: widget.isNotRunning ? NyamColors.grey50 : Colors.black,
            ),
          );
          break;
        case RestaurantType.ramen:
          mealsTitle = Text(
            "라면",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isNotRunning ? NyamColors.grey50 : Colors.black,
            ),
          );
          break;
        default:
          mealsTitle = Text(
            "기타",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isNotRunning ? NyamColors.grey50 : Colors.black,
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
              color: widget.isNotRunning ? NyamColors.grey50 : Colors.black,
            ),
          );
          break;
        case 1:
          mealsTitle = Text(
            "중식",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isNotRunning ? NyamColors.grey50 : Colors.black,
            ),
          );
          break;
        case 2:
          mealsTitle = Text(
            "석식",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isNotRunning ? NyamColors.grey50 : Colors.black,
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
                        isNotRunning: widget.isNotRunning,
                      ),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        if (!widget.isNotRunning) {
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
                                        fontSize: 16,
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
    required this.isNotRunning,
  });

  bool isNotRunning;

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
    if (widget.isNotRunning) {
      return;
    }
  }

  void setTitle() {
    if (widget.isNotRunning) {
      return;
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
