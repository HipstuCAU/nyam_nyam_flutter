import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';

class RestaurantPicker extends StatefulWidget {
  RestaurantPicker({
    super.key,
    required this.entryPoint,
    required this.isSelectedRestaurant,
    required this.seoulRestaurantName,
    required this.ansungRestaurantName,
  });

  final CampusType entryPoint;
  List<bool> isSelectedRestaurant;
  final List<String> seoulRestaurantName;
  final List<String> ansungRestaurantName;

  @override
  State<RestaurantPicker> createState() => _RestaurantPickerState();
}

class _RestaurantPickerState extends State<RestaurantPicker> {
  void touchUpToInsideToSelectRestaurant(int index) {
    setState(() {
      widget.isSelectedRestaurant = [
        false,
        false,
        false,
        false,
        false,
      ];
      widget.isSelectedRestaurant[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 14,
      ),
      child: SizedBox(
        height: 34,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.entryPoint == CampusType.seoul
              ? widget.seoulRestaurantName.length
              : widget.ansungRestaurantName.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(
                left: 10,
                // right: 10,
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                      spreadRadius: 1,
                      color: Colors.black.withOpacity(0.1),
                    )
                  ],
                  color: widget.isSelectedRestaurant[index]
                      ? NyamColors.cauBlue
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: GestureDetector(
                  onTap: () {
                    touchUpToInsideToSelectRestaurant(index);
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      widget.entryPoint == CampusType.seoul
                          ? widget.seoulRestaurantName[index]
                          : widget.ansungRestaurantName[index],
                      style: TextStyle(
                        color: widget.isSelectedRestaurant[index]
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
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
