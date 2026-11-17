import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// The SDK's codec is needed to simulate native ad events through its channel.
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nyam_nyam_flutter/widgets/ad_banner_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  Future<num?> Function(int width)? adaptiveHeight;
  var failNativeLoad = false;

  List<MethodCall> callsFor(String method) =>
      calls.where((call) => call.method == method).toList();

  Future<void> pumpBanner(WidgetTester tester, double width) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(width: width, child: const AdBannerWidget()),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> event(
    WidgetTester tester,
    int adId,
    String name, [
    Map<String, Object?> extra = const {},
  ]) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      instanceManager.channel.name,
      instanceManager.channel.codec.encodeMethodCall(
        MethodCall('onAdEvent', {'adId': adId, 'eventName': name, ...extra}),
      ),
      (_) {},
    );
    await tester.pump();
  }

  Future<void> removeBanner(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  setUp(() {
    calls.clear();
    adaptiveHeight = null;
    failNativeLoad = false;
    instanceManager = AdInstanceManager('plugins.flutter.io/google_mobile_ads');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(instanceManager.channel, (call) async {
      calls.add(call);
      if (failNativeLoad && call.method == 'loadBannerAd') {
        throw PlatformException(code: 'native-load-failure');
      }
      if (call.method == 'AdSize#getLargeAnchoredAdaptiveBannerAdSize') {
        return adaptiveHeight?.call(call.arguments['width'] as int) ?? 90;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(
      SystemChannels.platform_views,
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      SystemChannels.platform_views_2,
      (_) async => null,
    );
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(instanceManager.channel, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform_views_2, null);
  });

  testWidgets('공식 테스트 광고를 폭에 맞춰 한 번 로드하고 성공 후 표시한다', (tester) async {
    await pumpBanner(tester, 320);
    final load = callsFor('loadBannerAd').single.arguments as Map;
    final adId = load['adId'] as int;
    expect(load['adUnitId'], AdBannerWidget.testAdUnitId);
    expect((load['size'] as AdSize).width, 320);
    expect(find.byType(AdWidget), findsNothing);

    await event(tester, adId, 'onAdLoaded');
    expect(tester.getSize(find.byType(AdWidget)), const Size(320, 90));
    await pumpBanner(tester, 320);
    expect(callsFor('loadBannerAd'), hasLength(1));

    await removeBanner(tester);
    expect(callsFor('disposeAd'), hasLength(1));
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('로드 실패 시 광고를 해제하고 빈 공간을 남기지 않는다', (tester) async {
    await pumpBanner(tester, 320);
    final adId = callsFor('loadBannerAd').single.arguments['adId'] as int;
    await event(tester, adId, 'onAdFailedToLoad', {
      // Native LoadAdError fixtures use the SDK's protected constructor.
      // ignore: invalid_use_of_protected_member
      'loadAdError': LoadAdError(3, 'test', 'No fill', null),
    });
    expect(find.byType(AdWidget), findsNothing);
    expect(tester.getSize(find.byType(AdBannerWidget)).height, 0);
    expect(callsFor('disposeAd'), hasLength(1));
    await pumpBanner(tester, 320);
    expect(callsFor('loadBannerAd'), hasLength(1));
    await removeBanner(tester);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('폭 변경 시 이전 광고를 해제하고 새 폭으로 로드한다', (tester) async {
    await pumpBanner(tester, 320);
    final firstId = callsFor('loadBannerAd').single.arguments['adId'] as int;
    await event(tester, firstId, 'onAdLoaded');
    await pumpBanner(tester, 480);
    final loads = callsFor('loadBannerAd');
    expect(loads, hasLength(2));
    expect((loads.last.arguments['size'] as AdSize).width, 480);
    expect(instanceManager.isWidgetAdIdMounted(firstId), isFalse);
    expect(callsFor('disposeAd').single.arguments['adId'], firstId);
    expect(find.byType(AdWidget), findsNothing);
    await event(tester, loads.last.arguments['adId'] as int, 'onAdLoaded');
    expect(tester.getSize(find.byType(AdWidget)), const Size(480, 90));
    await removeBanner(tester);
    expect(callsFor('disposeAd'), hasLength(2));
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('이전 폭의 늦은 응답은 새 광고 요청을 덮어쓰지 않는다', (tester) async {
    final firstSize = Completer<num?>();
    adaptiveHeight = (width) async => width == 320 ? firstSize.future : 90;
    await pumpBanner(tester, 320);
    await pumpBanner(tester, 480);
    firstSize.complete(50);
    await tester.pump();
    expect(callsFor('loadBannerAd'), hasLength(1));
    expect(
      (callsFor('loadBannerAd').single.arguments['size'] as AdSize).width,
      480,
    );
    await removeBanner(tester);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('크기 조회 중 화면이 닫히면 광고를 생성하지 않는다', (tester) async {
    final pendingSize = Completer<num?>();
    adaptiveHeight = (_) => pendingSize.future;
    await pumpBanner(tester, 320);
    await removeBanner(tester);
    pendingSize.complete(90);
    await tester.pump();
    expect(callsFor('loadBannerAd'), isEmpty);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('네이티브 요청 예외에도 광고를 해제하고 앱 화면을 유지한다', (tester) async {
    failNativeLoad = true;
    await pumpBanner(tester, 320);
    expect(callsFor('loadBannerAd'), hasLength(1));
    expect(callsFor('disposeAd'), hasLength(1));
    expect(find.byType(AdWidget), findsNothing);
    expect(tester.getSize(find.byType(AdBannerWidget)).height, 0);
    await removeBanner(tester);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
