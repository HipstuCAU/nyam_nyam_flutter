import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("설정"),
      ),
      body: Row(
        children: const [
          Text("기본 캠퍼스 설정"),
        ],
      ),
    );
  }
}
