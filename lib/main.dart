import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nyam_nyam_flutter/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          const HomeScreen(),
          Positioned(
            bottom: 0,
            child: SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: AdBannerWidget(),
            ),
          )
        ],
      ),
    );
  }
}

class AdBannerWidget extends StatelessWidget {
  AdBannerWidget({
    super.key,
  });

  final adUnitId = kReleaseMode
      ? dotenv.env['RELEASE_ID'] ?? ''
      : dotenv.env['TEST_ID'] ?? '';

  @override
  Widget build(BuildContext context) {
    return AdWidget(
      ad: BannerAd(
        size: AdSize.fullBanner,
        adUnitId: adUnitId,
        listener: const BannerAdListener(),
        request: const AdRequest(),
      )..load(),
      key: UniqueKey(),
    );
  }
}
