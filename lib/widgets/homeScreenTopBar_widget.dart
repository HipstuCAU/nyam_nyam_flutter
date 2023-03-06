import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';

class HomeScreenTopBar extends StatelessWidget {
  const HomeScreenTopBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: TextButton.icon(
            onPressed: (() {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => CupertinoActionSheet(
                  title: const Text("캠퍼스를 선택해주세요."),
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      onPressed: () {
                        print("서울");
                      },
                      child: const Text(
                        "서울캠퍼스",
                      ),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () {
                        print("안성");
                      },
                      child: const Text(
                        "안성캠퍼스",
                      ),
                    ),
                  ],
                ),
              );
            }),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: NyamColors.customGrey,
              size: 35,
            ),
            label: const Text(
              "서울캠퍼스",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings),
          color: NyamColors.customGrey,
          iconSize: 25,
        )
      ],
    );
  }
}
