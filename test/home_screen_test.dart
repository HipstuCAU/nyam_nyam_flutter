import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/models/meal.dart';
import 'package:nyam_nyam_flutter/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

MealModel meal(DateTime date, String menu) => MealModel(
  date: date,
  openTime: [],
  restaurantType: RestaurantType.chamsulgi,
  mealTime: MealTime.lunch,
  mealType: MealType.korean,
  openType: OpenType.everyday,
  price: '5,500 원',
  menu: [menu],
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'favoriteCampus': '서울'});
  });

  Future<void> showHome(
    WidgetTester tester,
    Future<List<MealsForWeek>> Function() load,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: HomeScreen(loadMeals: load)));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('요청 중에는 로딩을 표시하고 빈 결과는 무한 로딩하지 않는다', (tester) async {
    final response = Completer<List<MealsForWeek>>();
    await showHome(tester, () => response.future);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('아직 등록된 식단이 없어요.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('다시 시도'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('조회 실패를 표시하고 다시 시도할 수 있다', (tester) async {
    var calls = 0;
    await showHome(tester, () async {
      calls++;
      if (calls == 1) throw StateError('offline');
      return [];
    });
    await tester.pumpAndSettle();
    expect(find.text('식단을 불러오지 못했어요.'), findsOneWidget);
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('아직 등록된 식단이 없어요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('오늘 식단이 없어도 다른 날짜를 선택하고 다시 조회하지 않는다', (tester) async {
    final tomorrow = DateUtils.dateOnly(DateTime.now())
        .add(const Duration(days: 1));
    var calls = 0;
    await showHome(tester, () async {
      calls++;
      return [
        {
          DateFormat('yyyy-MM-dd').format(tomorrow): [meal(tomorrow, '내일 메뉴')],
        },
        <String, List<MealModel>>{},
      ];
    });
    await tester.pumpAndSettle();
    expect(find.text('아직 등록된 식단이 없어요.'), findsOneWidget);
    await tester.tap(find.text(tomorrow.day.toString()));
    await tester.pumpAndSettle();
    expect(find.text('내일 메뉴'), findsOneWidget);
    expect(find.text('영업시간 정보 없음'), findsOneWidget);
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('날짜를 바꾸면 기존 화면의 메뉴를 갱신하고 컨트롤러와 조회 결과를 재사용한다', (tester) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    var calls = 0;
    await showHome(tester, () async {
      calls++;
      return [
        {
          DateFormat('yyyy-MM-dd').format(today): [meal(today, '오늘 메뉴')],
          DateFormat('yyyy-MM-dd').format(tomorrow): [meal(tomorrow, '내일 메뉴')],
        },
        <String, List<MealModel>>{},
      ];
    });
    await tester.pumpAndSettle();
    final controller = HomeScreen.pageController;
    expect(find.text('오늘 메뉴'), findsOneWidget);
    await tester.tap(find.text(tomorrow.day.toString()));
    await tester.pumpAndSettle();
    expect(find.text('내일 메뉴'), findsOneWidget);
    expect(find.text('오늘 메뉴'), findsNothing);
    expect(identical(controller, HomeScreen.pageController), isTrue);
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('완료 전에 화면을 닫아도 dispose 후 상태를 갱신하지 않는다', (tester) async {
    final response = Completer<List<MealsForWeek>>();
    await showHome(tester, () => response.future);
    await tester.pumpWidget(const SizedBox());
    response.complete([]);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  for (final height in [210.0, 220.0]) {
    testWidgets('높이 ${height.toInt()} 가로 화면에서도 헤더를 스크롤해 식단에 접근한다', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(729, height));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final today = DateUtils.dateOnly(DateTime.now());
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            loadMeals: () async => [
              {
                DateFormat('yyyy-MM-dd').format(today): [
                  meal(today, '가로화면 메뉴'),
                ],
              },
              <String, List<MealModel>>{},
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('서울캠퍼스').hitTestable(), findsOneWidget);

      await tester.drag(find.byType(NestedScrollView), const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(find.text('가로화면 메뉴').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(NestedScrollView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(find.text('서울캠퍼스').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
