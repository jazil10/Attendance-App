import 'package:flutter/material.dart';
import 'landing_page.dart';

void main() {
  runApp(SmartHCMApp());
}

class SmartHCMApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart HCM App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color.fromARGB(255, 1, 45, 56),
      ),
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
