import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';

class Menu extends StatefulWidget {
  Menu({
    super.key,
    required this.mealTime,
  });

  String mealTime;
  DateTime now = DateTime.now();

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late Icon icon;

  bool isOpenedToSee = true;

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
                    const Icon(
                      Icons.sunny_snowing,
                      size: 20,
                    ),
                    Text(
                      "  ${widget.mealTime}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 6,
                      bottom: 0,
                    ),
                    child: Text(
                      "3200원",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
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
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return const SizedBox(
                          child: Text(
                            "된장찌개",
                            style: TextStyle(
                              fontSize: 16,
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
