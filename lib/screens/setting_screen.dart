import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/screens/home_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({super.key});

  CampusType selectedCampus = CampusType.seoul;

  List<String> settingList = [
    '학교 포털 연결',
    '개인정보 정책',
    '문의하기',
  ];

  int campusRestaurantCount = 5;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Future initPreferences() async {
    final favoriteCampus = HomeScreen.preferences.getString('favoriteCampus');
    final sortedSeoulRestaurants =
        HomeScreen.preferences.getStringList('sortedSeoulRestaurants');
    final sortedAnsungRestaurants =
        HomeScreen.preferences.getStringList('sortedAnsungRestaurants');
    setState(() {
      if (favoriteCampus == '서울') {
        widget.selectedCampus = CampusType.seoul;
        widget.campusRestaurantCount = HomeScreen.seoulRestaurantName.length;
      } else {
        widget.selectedCampus = CampusType.ansung;
        widget.campusRestaurantCount = HomeScreen.ansungRestaurantName.length;
      }

      if (sortedSeoulRestaurants != null) {
        HomeScreen.seoulRestaurantName = sortedSeoulRestaurants;
      } else {
        HomeScreen.preferences.setStringList('sortedSeoulRestaurants', [
          '참슬기',
          '생활관A',
          '생활관B',
          '학생식당',
          '교직원',
        ]);
      }

      if (sortedAnsungRestaurants != null) {
        HomeScreen.ansungRestaurantName = sortedAnsungRestaurants;
      } else {
        HomeScreen.preferences.setStringList('sortedAnsungRestaurants', [
          '카우이츠',
          '카우버거',
          '라면',
        ]);
      }
    });
  }

  touchUpInsideToChangeFavoriteCampus(String campus) async {
    final favoriteCampus = HomeScreen.preferences.getString('favoriteCampus');
    if (favoriteCampus != null) {
      await HomeScreen.preferences.setString('favoriteCampus', campus);
      setState(() {
        if (campus == '서울') {
          widget.selectedCampus = CampusType.seoul;
          widget.campusRestaurantCount = HomeScreen.seoulRestaurantName.length;
          HomeScreen.entryPoint = CampusType.seoul;
        } else {
          widget.selectedCampus = CampusType.ansung;
          widget.campusRestaurantCount = HomeScreen.ansungRestaurantName.length;
          HomeScreen.entryPoint = CampusType.ansung;
        }
      });
    }
  }

  updateRestaurantSorting() async {
    if (widget.selectedCampus == CampusType.seoul) {
      await HomeScreen.preferences.setStringList(
          'sortedSeoulRestaurants', HomeScreen.seoulRestaurantName);
    } else {
      await HomeScreen.preferences.setStringList(
          'sortedAnsungRestaurants', HomeScreen.ansungRestaurantName);
    }
  }

  luanchURL(int index) async {
    const urls = [
      "https://mportal.cau.ac.kr/main.do",
      "https://haksik.notion.site/d579aa25f97b4d8a92ec6f18e90c4ff5"
    ];
    await launchUrlString(urls[index]);
  }

  sendEmail() async {
    final Email email = Email(
      body: '',
      subject: '[중대한학식 문의]',
      recipients: ['junhong5577@cau.ac.kr'],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      print("hi");
    } catch (error) {
      String title = "기본 메일 앱을 사용할 수 없는 상황입니다. 설정을 확인해주세요.";
      String message = "";
      print("error");
    }
  }

  @override
  void initState() {
    super.initState();
    initPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: NyamColors.customGrey,
        automaticallyImplyLeading: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
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
                                  touchUpInsideToChangeFavoriteCampus('서울');
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
                                  touchUpInsideToChangeFavoriteCampus('안성');
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
                          widget.selectedCampus == CampusType.seoul
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
                                    widget.selectedCampus == CampusType.seoul
                                        ? HomeScreen.seoulRestaurantName
                                            .removeAt(oldIndex)
                                        : HomeScreen.ansungRestaurantName
                                            .removeAt(oldIndex);
                                widget.selectedCampus == CampusType.seoul
                                    ? HomeScreen.seoulRestaurantName
                                        .insert(newIndex, item)
                                    : HomeScreen.ansungRestaurantName
                                        .insert(newIndex, item);
                                updateRestaurantSorting();
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
                                    margin: const EdgeInsets.all(0),
                                    padding: const EdgeInsets.only(
                                      left: 11,
                                    ),
                                    // color: Colors.white,
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
                                                    widget.selectedCampus ==
                                                            CampusType.seoul
                                                        ? HomeScreen
                                                                .seoulRestaurantName[
                                                            index]
                                                        : HomeScreen
                                                                .ansungRestaurantName[
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
                  child: GestureDetector(
                    onTap: () {
                      if (index == 0 || index == 1) {
                        luanchURL(index);
                      } else {
                        sendEmail();
                      }
                    },
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
