import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/screens/home_screen.dart';
import 'package:nyam_nyam_flutter/screens/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'favoriteCampus': '서울',
      'sortedSeoulRestaurants': ['교직원', '학생식당', '생활관B', '생활관A', '참슬기'],
      'sortedAnsungRestaurants': ['라면', '카우버거', '카우이츠'],
    });
    HomeScreen.preferences = await SharedPreferences.getInstance();
    HomeScreen.entryPoint = CampusType.seoul;
  });

  testWidgets('기존에 저장한 캠퍼스와 식당 순서를 읽는다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: SettingScreen()));
    await tester.pumpAndSettle();

    expect(find.text('서울'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(5));
    expect(
      find.descendant(
        of: find.byType(ListTile).first,
        matching: find.text('교직원'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('기본 캠퍼스 변경을 저장하고 해당 식당을 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: SettingScreen()));
    await tester.tap(find.text('기본 캠퍼스 설정'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('안성캠퍼스'));
    await tester.pumpAndSettle();

    expect(HomeScreen.preferences.getString('favoriteCampus'), '안성');
    expect(HomeScreen.entryPoint, CampusType.ansung);
    expect(find.text('안성'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
    expect(find.text('라면'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('식당을 아래로 옮긴 순서를 정확히 저장한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    HomeScreen.pageController = PageController();
    addTearDown(HomeScreen.pageController.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            Expanded(child: SettingScreen()),
            SizedBox(
              height: 1,
              child: PageView(
                controller: HomeScreen.pageController,
                children: const [SizedBox()],
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final destination = tester.getCenter(find.text('참슬기'));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('교직원')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(destination + const Offset(0, 80));
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(HomeScreen.preferences.getStringList('sortedSeoulRestaurants'), [
      '학생식당',
      '생활관B',
      '생활관A',
      '참슬기',
      '교직원',
    ]);
    expect(tester.takeException(), isNull);
  });
}
