import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/services/api_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('실제 Firestore 서버에서 양 캠퍼스의 현재 주간 식단을 읽는다', (tester) async {
    await Firebase.initializeApp();
    final document = await FirebaseFirestore.instance
        .collection('CAU_Haksik')
        .doc('CAU_Cafeteria_Menu')
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 30));
    expect(document.metadata.isFromCache, isFalse);
    final data = document.data();
    expect(data, isNotNull);
    final campuses = await ApiService().getMeals(data!);
    expect(campuses, hasLength(2));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));
    for (var index = 0; index < campuses.length; index++) {
      final days = campuses[index];
      expect(days, isNotEmpty, reason: '캠퍼스 $index의 파싱된 식단이 없습니다.');
      var rawCount = 0;
      final sourceDays = data['$index'] as Map<String, dynamic>;
      for (final times in sourceDays.values) {
        for (final restaurants in (times as Map<String, dynamic>).values) {
          for (final types in (restaurants as Map<String, dynamic>).values) {
            for (final meal in (types as Map<String, dynamic>).values) {
              final menu = (meal as Map<String, dynamic>)['menu'] as String?;
              if (menu != null &&
                  menu.split('|').any((item) => item.trim().isNotEmpty)) {
                rawCount++;
              }
            }
          }
        }
      }
      expect(
        days.values.fold(0, (total, meals) => total + meals.length),
        rawCount,
        reason: '캠퍼스 $index의 원본 식당 중 매핑되지 않은 식당이 있습니다.',
      );
      expect(
        days.keys
            .map(DateTime.parse)
            .any((date) => !date.isBefore(today) && date.isBefore(nextWeek)),
        isTrue,
        reason: '캠퍼스 $index에 현재 주간 식단이 없습니다.',
      );

      for (final entry in days.entries) {
        final date = DateTime.parse(entry.key);
        expect(
          entry.value.every((meal) => meal.date == date),
          isTrue,
          reason: '캠퍼스 $index ${entry.key}에 다른 날짜 식단이 섞였습니다.',
        );
        for (final meal in entry.value) {
          expect(meal.menu, isNotEmpty);
          expect(meal.menu.every((item) => item.trim().isNotEmpty), isTrue);
          expect(meal.price, matches(RegExp(r'^\s*[\d,]+\s*원\s*$')));
          expect(meal.openTime, hasLength(2));
          expect(meal.openTime.first.isBefore(meal.openTime.last), isTrue);
        }
      }
      final lists = days.values.toList();
      for (var i = 0; i < lists.length; i++) {
        for (var j = i + 1; j < lists.length; j++) {
          expect(identical(lists[i], lists[j]), isFalse);
        }
      }
      final dates = days.keys.toList()..sort();
      // Keep the server payload out of test logs; only emit diagnostic counts.
      // ignore: avoid_print
      print(
        'campus=$index meals=$rawCount dates=${dates.first}..${dates.last} '
        'checked=${DateFormat('yyyy-MM-dd').format(today)}',
      );
    }
  });
}
