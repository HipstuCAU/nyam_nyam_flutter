import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/screens/home_screen.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({super.key});

  CampusType favoriteCampus = CampusType.seoul;

  List<String> settingList = [
    '학교 포털 연결',
    '개인정보 정책',
    '문의하기',
  ];

  List<String> seoulRestaurantNames = [
    '참슬기',
    '생활관A',
    '생활관B',
    '학생식당',
    '교직원',
  ];
  List<String> ansungRestaurantNames = [
    '카우이츠',
    '카우버거',
    '라면',
  ];

  int campusRestaurantCount = 5;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: NyamColors.customGrey,
        title: const Text(
          "설정",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "기본 캠퍼스 설정",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => CupertinoActionSheet(
                          title: const Text("캠퍼스를 선택해주세요."),
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                              onPressed: () {
                                setState(() {
                                  widget.favoriteCampus = CampusType.seoul;
                                  widget.campusRestaurantCount =
                                      widget.seoulRestaurantNames.length;
                                  Navigator.pop(context, 'Cancel');
                                  HomeScreen.isSelectedRestaurant = [
                                    true,
                                    false,
                                    false,
                                    false,
                                    false,
                                  ];
                                });
                              },
                              child: const Text(
                                "서울캠퍼스",
                              ),
                            ),
                            CupertinoActionSheetAction(
                              onPressed: () {
                                setState(() {
                                  widget.favoriteCampus = CampusType.ansung;
                                  widget.campusRestaurantCount =
                                      widget.ansungRestaurantNames.length;
                                  Navigator.pop(context, 'Cancel');
                                  HomeScreen.isSelectedRestaurant = [
                                    true,
                                    false,
                                    false,
                                  ];
                                });
                              },
                              child: const Text(
                                "안성캠퍼스",
                              ),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            isDefaultAction: true,
                            onPressed: () {
                              Navigator.pop(context, 'Cancel');
                            },
                            child: const Text("취소"),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.favoriteCampus == CampusType.seoul
                              ? "서울"
                              : "안성",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 3, left: 8),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: NyamColors.customGrey,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      children: const [
                        Text(
                          "식당 순서 설정",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 12,
                          ),
                          child: Text(
                            "설정한 순서는 자동으로 저장돼요",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: NyamColors.grey50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 14,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                        minHeight: 0,
                      ),
                      child: ReorderableListView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          onReorder: (oldIndex, newIndex) {
                            setState(
                              () {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final String item =
                                    widget.favoriteCampus == CampusType.seoul
                                        ? widget.seoulRestaurantNames
                                            .removeAt(oldIndex)
                                        : widget.ansungRestaurantNames
                                            .removeAt(oldIndex);
                                widget.favoriteCampus == CampusType.seoul
                                    ? widget.seoulRestaurantNames
                                        .insert(newIndex, item)
                                    : widget.ansungRestaurantNames
                                        .insert(newIndex, item);
                              },
                            );
                          },
                          children: <Widget>[
                            for (int index = 0;
                                index < widget.campusRestaurantCount;
                                index++)
                              ListTile(
                                key: Key('$index'),
                                title: Container(
                                    padding: const EdgeInsets.only(
                                      left: 6,
                                    ),
                                    color: Colors.white,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 6, right: 24),
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: NyamColors.customGrey,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: Text(
                                              "${index + 1}",
                                              style: const TextStyle(
                                                fontSize: 8,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: NyamColors.grey50
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    widget.favoriteCampus ==
                                                            CampusType.seoul
                                                        ? widget.seoulRestaurantNames[
                                                            index]
                                                        : widget.ansungRestaurantNames[
                                                            index],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          NyamColors.customGrey,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: Image.asset(
                                                        'assets/images/equal.png'),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              )
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            color: Colors.white,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 16,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.settingList[index],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: NyamColors.customGrey,
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => Container(
                color: NyamColors.grey50.withOpacity(0.5),
                child: const SizedBox(height: 1),
              ),
              itemCount: 3,
            ),
          )
        ],
      ),
    );
  }
}
