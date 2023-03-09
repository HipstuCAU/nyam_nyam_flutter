import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: NyamColors.customGrey,
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
      body: Row(
        children: const [
          Text("기본 캠퍼스 설정"),
        ],
      ),
    );
  }
}
