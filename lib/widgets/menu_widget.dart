import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';

class Menu extends StatefulWidget {
  Menu({
    super.key,
    required this.mealsForDay,
    required this.isBurgerOrRamen,
  });

  MealsForDay mealsForDay;
  bool isBurgerOrRamen;
  DateTime now = DateTime.now();

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Icon icon = const Icon(
    Icons.nights_stay,
    size: 20,
  );

  bool isOpenedToSee = true;
  String mealsTitle = "";

  @override
  void initState() {
    super.initState();
    setIcon();
    setTitle();
  }

  void setIcon() {
    if (widget.mealsForDay.isNotEmpty) {
      switch (widget.mealsForDay[0].mealTime) {
        case MealTime.breakfast:
          icon = const Icon(
            Icons.sunny_snowing,
            size: 20,
          );
          break;
        case MealTime.lunch:
          icon = const Icon(
            Icons.sunny,
            size: 20,
          );
          break;
        case MealTime.dinner:
          icon = const Icon(
            Icons.nights_stay,
            size: 20,
          );
          break;
        default:
          icon = const Icon(
            Icons.nights_stay,
            size: 20,
          );
          break;
      }
    }
  }

  void setTitle() {
    if (widget.mealsForDay.isNotEmpty) {
      if (widget.isBurgerOrRamen) {
        switch (widget.mealsForDay[0].restaurantType) {
          case RestaurantType.cauBurger:
            mealsTitle = "카우버거";
            break;
          case RestaurantType.ramen:
            mealsTitle = "라면";
            break;
          default:
            mealsTitle = "기타";
            break;
        }
      } else {
        switch (widget.mealsForDay[0].mealTime) {
          case MealTime.breakfast:
            mealsTitle = "조식";
            break;
          case MealTime.lunch:
            mealsTitle = "중식";
            break;
          case MealTime.dinner:
            mealsTitle = "석식";
            break;
        }
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
                      child: Text(
                        mealsTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: OpenState(),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        isOpenedToSee = !isOpenedToSee;
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

class OpenState extends StatelessWidget {
  const OpenState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NyamColors.customYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        child: Text(
          "준비중",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: NyamColors.customYellow,
          ),
        ),
      ),
    );
  }
}
