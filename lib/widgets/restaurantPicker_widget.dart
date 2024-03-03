import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/screens/home_screen.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class RestaurantPicker extends StatefulWidget {
  const RestaurantPicker({
    super.key,
    required this.seoulRestaurantName,
    required this.ansungRestaurantName,
  });

  final List<String> seoulRestaurantName;
  final List<String> ansungRestaurantName;

  @override
  State<RestaurantPicker> createState() => _RestaurantPickerState();
}

class _RestaurantPickerState extends State<RestaurantPicker> {
  void touchUpToInsideToSelectRestaurant(int index) {
    setState(() {
      HomeScreen.isSelectedRestaurant = [
        false,
        false,
        false,
        false,
        false,
      ];
      HomeScreen.isSelectedRestaurant[index] = true;
      HomeScreen.pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: SizedBox(
        height: 55,
        child: ListView.builder(
          controller: HomeScreen.autoScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: HomeScreen.entryPoint == CampusType.seoul
              ? widget.seoulRestaurantName.length
              : widget.ansungRestaurantName.length,
          itemBuilder: (context, index) {
            return AutoScrollTag(
              key: ValueKey(index),
              controller: HomeScreen.autoScrollController,
              index: index,
              child: Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 20 : 10,
                  top: 5,
                  bottom: 10,
                  right:
                      index == widget.seoulRestaurantName.length - 1 ? 20 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    touchUpToInsideToSelectRestaurant(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: HomeScreen.isSelectedRestaurant[index]
                          ? NyamColors.cauBlue
                          : NyamColors.customSkyBlue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    clipBehavior: Clip.none,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17.25,
                        vertical: 10.25,
                      ),
                      child: Center(
                        child: Text(
                          HomeScreen.entryPoint == CampusType.seoul
                              ? widget.seoulRestaurantName[index]
                              : widget.ansungRestaurantName[index],
                          style: TextStyle(
                            color: HomeScreen.isSelectedRestaurant[index]
                                ? Colors.white
                                : NyamColors.customBlack,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
