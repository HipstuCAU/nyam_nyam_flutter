import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nyam_nyam_flutter/screens/home_screen.dart';
import 'package:nyam_nyam_flutter/widgets/ad_banner_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화를 dotenv 로드 전에 수행
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  MobileAds.instance.initialize();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: HomeScreen()),
              AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
