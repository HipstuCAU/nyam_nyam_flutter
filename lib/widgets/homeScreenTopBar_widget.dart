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
        TextButton.icon(
          onPressed: (() {}),
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
