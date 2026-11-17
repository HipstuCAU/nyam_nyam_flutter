import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/models/meal.dart';
import 'package:nyam_nyam_flutter/widgets/menu_widget.dart';
import 'package:nyam_nyam_flutter/screens/home_screen.dart';

MealModel meal(
  List<String> menu, {
  List<DateTime> hours = const [],
  OpenType openType = OpenType.everyday,
  DateTime? date,
  RestaurantType restaurantType = RestaurantType.student,
  MealTime mealTime = MealTime.lunch,
}) => MealModel(
  date: date ?? DateTime(2026, 11, 17),
  openTime: hours,
  restaurantType: restaurantType,
  mealTime: mealTime,
  mealType: MealType.korean,
  openType: openType,
  price: '5,500 원',
  menu: menu,
);

void main() {
  Future<void> showMenu(
    WidgetTester tester,
    List<MealModel> meals, {
    String restaurantName = '학생식당',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Menu(
            mealsForDay: meals,
            restaurantName: restaurantName,
            timeIndex: 1,
            isTodayMeals: false,
          ),
        ),
      ),
    );
  }

  testWidgets('메뉴를 표시하기 위해 원본 리스트를 정렬하거나 덮어쓰지 않는다', (tester) async {
    final single = meal(['단품']);
    final set = meal(['정식', '국']);
    final original = [single, set];
    await showMenu(tester, original);
    expect(identical(original.first, single), isTrue);
    expect(identical(original.last, set), isTrue);
    expect(find.text('단품'), findsOneWidget);
    expect(find.text('정식'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('영업시간 누락과 단일 시각은 미운영으로 단정하거나 예외를 만들지 않는다', (tester) async {
    await showMenu(tester, [
      meal(['메뉴']),
    ]);
    expect(find.text('영업시간 정보 없음'), findsOneWidget);
    await showMenu(tester, [
      meal(['변경 메뉴'], hours: [DateTime(1970, 1, 1, 11)]),
    ]);
    expect(find.text('영업시간 정보 없음'), findsOneWidget);
    expect(find.text('변경 메뉴'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('정상 영업시간이 있어도 휴무 식단은 미운영으로 표시한다', (tester) async {
    await showMenu(tester, [
      meal(
        ['운영없음'],
        openType: OpenType.closed,
        hours: [DateTime(1970, 1, 1, 11), DateTime(1970, 1, 1, 14)],
      ),
    ]);
    expect(find.text('미운영'), findsOneWidget);
    expect(find.textContaining('준비중'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('주말휴무 표기는 주말 날짜에만 미운영이다', (tester) async {
    await showMenu(tester, [
      meal(
        ['메뉴'],
        openType: OpenType.closeOnWeekends,
        date: DateTime(2026, 11, 17),
      ),
    ]);
    expect(find.text('미운영'), findsNothing);
    await showMenu(tester, [
      meal(
        ['주말운영없음'],
        openType: OpenType.closeOnWeekends,
        date: DateTime(2026, 11, 21),
      ),
    ]);
    expect(find.text('미운영'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('카우버거 카드에 모든 시간대 메뉴와 유효한 영업시간 범위를 표시한다', (tester) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final meals = [
      meal(
        ['오전 버거'],
        date: tomorrow,
        restaurantType: RestaurantType.cauBurger,
        mealTime: MealTime.breakfast,
        hours: [DateTime(1970, 1, 1, 9, 30), DateTime(1970, 1, 1, 11)],
      ),
      meal(
        ['오후 버거'],
        date: tomorrow,
        restaurantType: RestaurantType.cauBurger,
        mealTime: MealTime.lunch,
        hours: [DateTime(1970, 1, 1, 11), DateTime(1970, 1, 1, 16, 30)],
      ),
      meal(
        ['시간 누락 버거'],
        date: tomorrow,
        restaurantType: RestaurantType.cauBurger,
        mealTime: MealTime.dinner,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MealsOfRestaurant(mealsForDay: meals, restaurantName: '카우버거'),
        ),
      ),
    );
    expect(find.text('오전 버거'), findsOneWidget);
    expect(find.text('오후 버거'), findsOneWidget);
    expect(find.text('시간 누락 버거'), findsOneWidget);
    expect(find.text('준비중 09:30~16:30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('카우버거와 라면도 영업시간을 추측하지 않는다', (tester) async {
    for (final restaurant in ['카우버거', '라면']) {
      await showMenu(tester, [
        meal(['메뉴']),
      ], restaurantName: restaurant);
      expect(find.text('영업시간 정보 없음'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('같은 라면 메뉴는 한 번만 표시하되 모든 시간대에서 영업시간을 집계한다', (tester) async {
    final originals = [
      meal(
        ['라면 메뉴'],
        hours: [DateTime(1970, 1, 1, 6), DateTime(1970, 1, 1, 11)],
      ),
      meal(
        ['라면 메뉴'],
        hours: [DateTime(1970, 1, 1, 11), DateTime(1970, 1, 1, 16)],
      ),
      meal(
        ['라면 메뉴'],
        hours: [DateTime(1970, 1, 1, 16, 1), DateTime(1970, 1, 1, 23)],
      ),
    ];
    await showMenu(tester, originals, restaurantName: '라면');
    expect(find.text('라면 메뉴'), findsOneWidget);
    expect(find.text('준비중 06:00~23:00'), findsOneWidget);
    expect(originals, hasLength(3));
    expect(originals.last.openTime.last.hour, 23);
    expect(tester.takeException(), isNull);
  });
}
