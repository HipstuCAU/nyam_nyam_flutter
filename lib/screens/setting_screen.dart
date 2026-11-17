import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/screens/home_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  CampusType selectedCampus = CampusType.seoul;
  static const settingList = ['학교 포털 연결', '개인정보 정책', '문의하기'];

  int get campusRestaurantCount => selectedCampus == CampusType.seoul
      ? HomeScreen.seoulRestaurantName.length
      : HomeScreen.ansungRestaurantName.length;

  @override
  void initState() {
    super.initState();
    initPreferences();
  }

  Future<void> initPreferences() async {
    await HomeScreen.restoreRestaurantOrders();
    if (!mounted) return;
    setState(() {
      selectedCampus =
          HomeScreen.preferences.getString('favoriteCampus') == '안성'
          ? CampusType.ansung
          : CampusType.seoul;
    });
  }

  Future<void> touchUpInsideToChangeFavoriteCampus(String campus) async {
    setState(() {
      selectedCampus = campus == '서울' ? CampusType.seoul : CampusType.ansung;
      HomeScreen.entryPoint = selectedCampus;
      initializeRestaurantPicker();
    });
    await HomeScreen.preferences.setString('favoriteCampus', campus);
  }

  Future<void> updateRestaurantSorting() async {
    if (selectedCampus == CampusType.seoul) {
      await HomeScreen.preferences.setStringList(
        'sortedSeoulRestaurants',
        HomeScreen.seoulRestaurantName,
      );
    } else {
      await HomeScreen.preferences.setStringList(
        'sortedAnsungRestaurants',
        HomeScreen.ansungRestaurantName,
      );
    }
  }

  void initializeRestaurantPicker() {
    HomeScreen.isSelectedRestaurant = List.generate(
      campusRestaurantCount,
      (index) => index == 0,
    );
  }

  Future<void> luanchURL(int index) async {
    const urls = [
      "https://mportal.cau.ac.kr/main.do",
      "https://docs.google.com/document/d/1bpCB8lzZzmw1yTrK54HRttgz3kWzHao_EyYe91kpiFw/edit?usp=sharing",
    ];
    await launchUrlString(urls[index]);
  }

  Future<void> sendEmail() async {
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('메일 앱을 열 수 없어요.')));
    }
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
          },
        ),
        titleSpacing: 0,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoActionSheet(
                    title: const Text("캠퍼스를 선택해주세요."),
                    actions: <Widget>[
                      CupertinoActionSheetAction(
                        onPressed: () {
                          touchUpInsideToChangeFavoriteCampus('서울');
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "서울캠퍼스",
                          style: TextStyle(color: NyamColors.cauBlue),
                        ),
                      ),
                      CupertinoActionSheetAction(
                        onPressed: () {
                          touchUpInsideToChangeFavoriteCampus('안성');
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "안성캠퍼스",
                          style: TextStyle(color: NyamColors.cauBlue),
                        ),
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      isDefaultAction: true,
                      onPressed: () {
                        Navigator.pop(context, 'Cancel');
                      },
                      child: const Text(
                        "취소",
                        style: TextStyle(color: NyamColors.cauBlue),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            selectedCampus == CampusType.seoul ? "서울" : "안성",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            "식당 순서 설정",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12),
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
                      padding: const EdgeInsets.only(top: 14),
                      child: ReorderableListView(
                        physics: const NeverScrollableScrollPhysics(),
                        primary: false,
                        shrinkWrap: true,
                        onReorderItem: (oldIndex, newIndex) {
                          setState(() {
                            final String item =
                                selectedCampus == CampusType.seoul
                                ? HomeScreen.seoulRestaurantName.removeAt(
                                    oldIndex,
                                  )
                                : HomeScreen.ansungRestaurantName.removeAt(
                                    oldIndex,
                                  );
                            selectedCampus == CampusType.seoul
                                ? HomeScreen.seoulRestaurantName.insert(
                                    newIndex,
                                    item,
                                  )
                                : HomeScreen.ansungRestaurantName.insert(
                                    newIndex,
                                    item,
                                  );
                            updateRestaurantSorting();
                            initializeRestaurantPicker();
                            if (HomeScreen.pageController.hasClients) {
                              HomeScreen.pageController.jumpToPage(0);
                            }
                          });
                        },
                        children: <Widget>[
                          for (
                            int index = 0;
                            index < campusRestaurantCount;
                            index++
                          )
                            ListTile(
                              key: Key('$index'),
                              title: Container(
                                margin: const EdgeInsets.all(0),
                                padding: const EdgeInsets.only(left: 11),
                                // color: Colors.white,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 6,
                                        right: 24,
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: NyamColors.customGrey,
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
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
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                selectedCampus ==
                                                        CampusType.seoul
                                                    ? HomeScreen
                                                          .seoulRestaurantName[index]
                                                    : HomeScreen
                                                          .ansungRestaurantName[index],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: NyamColors.customGrey,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Image.asset(
                                                  'assets/images/equal.png',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (index == 0 || index == 1) {
                        luanchURL(index);
                      } else {
                        sendEmail();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 16,
                        top: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            settingList[index],
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
                  color: NyamColors.grey50.withValues(alpha: 0.5),
                  child: const SizedBox(height: 1),
                ),
                itemCount: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
