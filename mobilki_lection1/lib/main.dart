import 'package:flutter/material.dart';

import 'screens/layouts_home.dart';

void main() {
  runApp(const MeditownApp());
}

class MeditownApp extends StatelessWidget {
  const MeditownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'medinow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const LayoutsHome(),
    );
  }
}