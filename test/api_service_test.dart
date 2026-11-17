import 'package:flutter_test/flutter_test.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/services/api_service.dart';

Map<String, dynamic> meal({
  String? menu = '메뉴',
  String price = '5,500 원',
  String? time = '11:00~13:30',
}) => {'menu': menu, 'price': price, 'time': ?time};

Map<String, dynamic> day(
  Map<String, dynamic> menus, {
  String restaurant = '참슬기식당(310관 B4층)',
}) => {
  '1': {restaurant: menus},
};

void main() {
  final service = ApiService();

  test('날짜와 캠퍼스별 식단은 서로 다른 목록으로 묶인다', () async {
    final result = await service.getMeals({
      '0': {
        '2026.11.17': day({
          '중식(한식)': meal(menu: '서울17-한식'),
          '중식(양식)': meal(menu: '서울17-양식'),
        }),
        '2026.11.18': day({'중식(특식)': meal(menu: '서울18')}),
      },
      '1': {
        '2026.11.17': day({
          '중식(한식)': meal(menu: '안성17'),
        }, restaurant: '카우잇츠(cau eats)'),
      },
    });

    expect(result[0]['2026-11-17']!.map((m) => m.menu.single), [
      '서울17-한식',
      '서울17-양식',
    ]);
    expect(result[0]['2026-11-18']!.single.menu, ['서울18']);
    expect(result[1]['2026-11-17']!.single.menu, ['안성17']);
    result[0]['2026-11-17']!.clear();
    expect(result[0]['2026-11-18'], hasLength(1));
    expect(result[1]['2026-11-17'], hasLength(1));
  });

  test('영업시간은 24시간제로 읽고 누락된 시간에 이전 식당 시간이 섞이지 않는다', () async {
    final result = await service.getMeals({
      '0': {
        '2026.11.17': day({
          '석식(한식)': meal(menu: '정상', time: '17:30 ~ 19:00'),
          '석식(양식)': meal(menu: '시간누락', time: null),
          '석식(특식)': meal(menu: '단일시각', time: '18:30'),
        }),
      },
      '1': <String, dynamic>{},
    });
    final meals = result[0]['2026-11-17']!;
    expect(meals[0].openTime.map((t) => '${t.hour}:${t.minute}'), [
      '17:30',
      '19:0',
    ]);
    expect(meals[1].openTime, isEmpty);
    expect(meals[2].openTime.single.hour, 18);
    expect(meals[2].openTime.single.minute, 30);
  });

  test('잘못된 영업시간은 다른 식단을 중단시키거나 자정으로 표시하지 않는다', () async {
    final result = await service.getMeals({
      '0': {
        '2026.11.17': day({
          '중식(한식)': meal(time: '운영종료'),
          '중식(양식)': meal(time: '11:00~25:00'),
          '중식(특식)': meal(time: '11:30~14:00'),
        }),
      },
      '1': <String, dynamic>{},
    });
    final meals = result[0]['2026-11-17']!;
    expect(meals[0].openTime, isEmpty);
    expect(meals[1].openTime, isEmpty);
    expect(meals[2].openTime.map((t) => t.hour), [11, 14]);
  });

  test('구분자 주변 공백과 빈 메뉴를 제거하고 가격과 식사 종류를 보존한다', () async {
    final result = await service.getMeals({
      '0': {
        '2026.11.17': day({
          '중식(양식)': meal(menu: '  밥 | 국 || 반찬 | ', price: '6,000 원'),
          '중식(특식)': meal(menu: ''),
          '중식(한식)': meal(menu: null),
          '중식(한식1)': meal(menu: '  |  '),
        }),
      },
      '1': <String, dynamic>{},
    });
    final parsed = result[0]['2026-11-17']!.single;
    expect(parsed.menu, ['밥', '국', '반찬']);
    expect(parsed.price, '6,000 원');
    expect(parsed.mealType, MealType.western);
    expect(parsed.mealTime, MealTime.lunch);
  });

  test('빈 데이터와 한 캠퍼스만 등록된 데이터도 읽을 수 있다', () async {
    expect(await service.getMeals({}), isEmpty);
    final result = await service.getMeals({
      '1': {
        '2026.11.17': day({'중식(한식)': meal()}, restaurant: '카우잇츠(cau eats)'),
      },
    });
    expect(result[0], isEmpty);
    expect(result[1]['2026-11-17'], hasLength(1));
  });

  test('일반 휴무와 주말 휴무를 실제 영업시간과 별도로 구분한다', () async {
    final result = await service.getMeals({
      '0': {
        '2026.11.17': day({
          '중식(한식)': meal(menu: '운영없음', price: '0 원'),
          '중식(양식)': meal(menu: ' 주말운영없음 '),
          '중식(특식)': meal(menu: '휴무'),
          '중식(한식1)': meal(),
        }),
      },
      '1': <String, dynamic>{},
    });
    expect(result[0]['2026-11-17']!.map((m) => m.openType), [
      OpenType.closed,
      OpenType.closeOnWeekends,
      OpenType.closed,
      OpenType.everyday,
    ]);
  });

  test('다빈치 식당명과 University Club을 기존 식당과 섞지 않는다', () async {
    final result = await service.getMeals({
      '0': {
        '2026.11.17': {
          '1': {
            'University Club(102관11층)': {'중식(한식)': meal(menu: '클럽')},
            '교직원식당(303관B1층)': {'중식(한식)': meal(menu: '교직원')},
            '알 수 없는 식당': {'중식(한식)': meal(menu: '다른식당')},
          },
        },
      },
      '1': {
        '2026.11.17': {
          '1': {
            '(다빈치)라면': {'중식(한식)': meal(menu: '다빈치라면')},
            '(안성)라면': {'중식(한식)': meal(menu: '안성라면')},
            '(다빈치)카우버거': {'중식(한식)': meal(menu: '다빈치버거')},
            '(안성)카우버거': {'중식(한식)': meal(menu: '안성버거')},
          },
        },
      },
    });
    expect(result[0]['2026-11-17']!.map((m) => m.restaurantType), [
      RestaurantType.universityClub,
      RestaurantType.staff,
    ]);
    expect(result[1]['2026-11-17']!.map((m) => m.restaurantType), [
      RestaurantType.ramen,
      RestaurantType.ramen,
      RestaurantType.cauBurger,
      RestaurantType.cauBurger,
    ]);
  });
}
